# Llama.cpp Server (Qwen-3.5 35B Optimized)

This is a RunPod container image based on `ghcr.io/ggml-org/llama.cpp`.

It includes:

- Llama.cpp Server (running on port 8080)
- Automatic download and startup with Qwen 3.5 35B GGUF
- Python & Jupyter
- RunPod standard utilities (Nginx, Proxy, etc.)

## Custom Startup

The container uses `post_start.sh` to download the model and start the server.

- **Port:** 8080 (Proxied through 8081 for external use)
- **Model:** Qwen3.5-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf

## Version Management

The base image version is managed via the `LLAMA_CPP_VERSION` variable in `docker-bake.hcl`.
Current version: `b8783`

To build with a different version:

1. Update `LLAMA_CPP_VERSION` in `docker-bake.hcl`.
2. Run `./bake.sh llama-cpp-server-cuda12`.

The resulting image will be tagged as `shennguyenrs/llama-cpp-server-cuda12:<LLAMA_CPP_VERSION>` (e.g., `shennguyenrs/llama-cpp-server-cuda12:b8783`).
