"""Stable Diffusion for Nextcloud Talk"""

import io
import queue
import re
import threading
from contextlib import asynccontextmanager
from datetime import datetime
from time import perf_counter
from typing import Annotated, Any

import torch
from diffusers import AutoPipelineForText2Image
from fastapi import BackgroundTasks, Depends, FastAPI, Response
from huggingface_hub import snapshot_download
from nc_py_api import AsyncNextcloudApp, NextcloudApp
from nc_py_api.ex_app import (
    LogLvl,
    anc_app,
    atalk_bot_msg,
    persistent_storage,
    run_app,
    set_handlers,
)
from nc_py_api.talk_bot import AsyncTalkBot, TalkBotMessage

MODEL_NAME = "stabilityai/sdxl-turbo"
MODEL_RUNTIME_OPT = {
    "torch_dtype": torch.float32,
    "variant": "fp32",
}


@asynccontextmanager
async def lifespan(_app: FastAPI):
    if torch.cuda.is_available() or torch.backends.mps.is_available():
        allow_patterns = ["*.fp16.safetensors", "*.json", "*.txt"]
        ignore_patterns = None
        MODEL_RUNTIME_OPT["torch_dtype"] = torch.float16
        MODEL_RUNTIME_OPT["variant"] = "fp16"
    else:
        allow_patterns = None
        ignore_patterns = ["*onnx*", "*fp16*", "sd_xl_turbo_1*"]
    set_handlers(
        APP,
        enabled_handler,
        models_to_fetch={
            MODEL_NAME: {
                "allow_patterns": allow_patterns,
                "ignore_patterns": ignore_patterns,
            }
        },
    )
    t = BackgroundProcessTask()
    t.start()
    yield


APP = FastAPI(lifespan=lifespan)
SD_BOT = AsyncTalkBot(
    "/stable_diffusion",
    "Stable Diffusion",
    "@image cinematic shot of black pug wearing italian priest robe.",
)
TASK_LIST: queue.Queue = queue.Queue(maxsize=10)
PIPE: Any = None


class BackgroundProcessTask(threading.Thread):
    def run(self, *args, **kwargs):  # pylint: disable=unused-argument
        global PIPE

        while True:
            try:
                task: TalkBotMessage = TASK_LIST.get(block=True, timeout=60 * 60)
                if PIPE is None:
                    print("loading model")
                    time_start = perf_counter()
                    PIPE = AutoPipelineForText2Image.from_pretrained(
                        snapshot_download(
                            MODEL_NAME,
                            local_files_only=True,
                            cache_dir=persistent_storage(),
                        ),
                        **MODEL_RUNTIME_OPT,
                    )
                    if torch.cuda.is_available():
                        PIPE.to("cuda")
                    elif torch.backends.mps.is_available():
                        PIPE.to("mps")
                    print(f"model loaded: {perf_counter() - time_start}s")

                r = re.search(r"@image\s(.*)", task.object_content["message"], re.IGNORECASE)
                print("generating image")
                time_start = perf_counter()
                im = PIPE(prompt=r.group(1), num_inference_steps=1, guidance_scale=0.0).images[0]  # mypy
                print(f"image generated: {perf_counter() - time_start}s")
                nc = NextcloudApp()
                nc.set_user(task.actor_id[len("users/") :])
                nc.files.makedirs("image_generator_bot", exist_ok=True)
                im_out = io.BytesIO()
                im.save(im_out, format="PNG")
                im_out.seek(0)
                new_im = nc.files.upload_stream(
                    f"image_generator_bot/{datetime.now().strftime('%Y-%m-%d-%H-%M-%S.%f')}.png",
                    im_out,
                )
                nc.talk.send_file(new_im, task.conversation_token)
                im = nc = im_out = None  # noqa
            except queue.Empty:
                if PIPE:
                    print("offloading model")
                PIPE = None
            except Exception as e:  # noqa
                print(str(e))
                NextcloudApp().log(LogLvl.ERROR, str(e))


async def stable_diffusion_process_request(message: TalkBotMessage):
    try:
        TASK_LIST.put(message, block=False)
        print("task added")
    except queue.Full:
        await SD_BOT.send_message("*Task queue is full*", message)
        print("queue full")


@APP.post("/stable_diffusion")
async def stable_diffusion(
    message: Annotated[TalkBotMessage, Depends(atalk_bot_msg)],
    _nc: Annotated[AsyncNextcloudApp, Depends(anc_app)],
    background_tasks: BackgroundTasks,
):
    if message.object_name == "message" and message.actor_id.startswith("users/"):
        r = re.search(r"@image\s(.*)", message.object_content["message"], re.IGNORECASE)
        if r is not None:
            background_tasks.add_task(stable_diffusion_process_request, message)
    return Response()


async def enabled_handler(enabled: bool, nc: AsyncNextcloudApp) -> str:
    global PIPE

    print(f"enabled={enabled}")
    try:
        await SD_BOT.enabled_handler(enabled, nc)
        if enabled is False:
            PIPE = None
    except Exception as e:
        return str(e)
    return ""


if __name__ == "__main__":
    run_app("main:APP", log_level="trace")
