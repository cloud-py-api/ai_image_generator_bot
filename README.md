# Nextcloud AI Image generator bot

Uses [SDXL-Turbo](https://huggingface.co/stabilityai/sdxl-turbo) for fast image generation.

*Using the RTX 3060 12GB, bot is capable of processing 2 requests per second.*

> [!WARNING]
> Note: Model loaded in GPU memory uses ~9.4GB.
> Can be run on CPU but will require ~2x of memory.
>
> Models remain in memory after a request, for faster processing of subsequent requests.
>
> Memory is freed after an hour of inactivity.

![Enable talk bot](/screenshots/ai_image_generator_bot_1.png)
![Send prompts](/screenshots/ai_image_generator_bot_2.png)

## How to use

1. Install ExApp from AppStore
2. Wait for models download and initialization(`6.5` Gb for GPU, `13` Gb for CPU)
3. Enable talk bot in your room
4. Use @image mention to send prompts: `@image cinematic portrait of fluffy cat with black eyes`
5. Image will be posted to room and stored into `image_generator_bot` folder at the user's root.

> [!IMPORTANT]
> Only English language is supported

## State of support

The project is being developed in personal and free time, any ideas or pull requests are welcome.
