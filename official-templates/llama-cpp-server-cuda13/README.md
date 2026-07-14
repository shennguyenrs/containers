# Llama.cpp Server (Qwen-3.6 35B Optimized)

A RunPod-optimized container image featuring the [llama.cpp](https://github.com/ggml-org/llama.cpp) server, pre-configured with the **Qwen 3.6 35B A3B Uncensored** model.

## Features

- **Llama.cpp Server:** Optimized for CUDA 12.x environments.
- **Model Included:** Automatically downloads and runs [Qwen-3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf](https://huggingface.co/HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive).
- **RunPod Optimized:** Includes standard RunPod utilities (Nginx, Proxy, SSH, Filebrowser).
- **Python Stack:** Multiple Python versions (3.9 to 3.13), JupyterLab, and `uv` for fast package management.
- **Thinking Support:** Optimized for models with reasoning/thinking capabilities.

## Running Specifications

The container is configured with the following optimized flags for the Qwen 3.6 35B model. This command is executed automatically on startup via `/post_start.sh`:

```bash
/app/llama-server \
    -m /workspace/models/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf \
    --host 0.0.0.0 \
    --port 8080 \
    -c 204800 \
    -ngl 99 \
    -t 4 \
    --jinja \
    --chat-template-kwargs '{"enable_thinking": true,"preserve_thinking": true}' \
    --flash-attn auto \
    --cache-type-k q8_0 \
    --cache-type-v q8_0 \
    --batch-size 1024
```

### Key Specs:
- **Context Window:** 204,800 tokens (`-c 204800`)
- **GPU Offloading:** 99 layers (Full GPU offload)
- **KV Cache:** Quantized to Q8_0 for memory efficiency at high context.
- **Inference:** Flash Attention enabled (`--flash-attn auto`).

## Usage & Verification

### How to check active specs
Once the container is running, you can verify the server configuration by calling the `/props` endpoint:

```bash
curl http://localhost:8080/props
```

### RunPod (Recommended)
This image is designed to be used as a template on RunPod. 
- **Port 8080:** The `llama.cpp` server (proxied to 8081 for external access).
- **Port 8888:** JupyterLab.
- **Port 22:** SSH.
- **Port 80:** Filebrowser.

### Local Execution (Docker)
To run this locally with GPU support:

```bash
docker run --gpus all -p 8080:8080 -v $(pwd)/workspace:/workspace shennguyenrs/llama-cpp-server-cuda12:b8882
```

> **Hardware Requirement:** This model (~24GB) and its large context window require a GPU with at least **32GB - 48GB VRAM** (e.g., A6000, A100, or H100) for optimal performance at full context.

## Configuration

The base image version and tags are managed via `docker-bake.hcl`. 
- **Base Image:** `ghcr.io/ggml-org/llama.cpp:server-cuda12-b8882`
- **GitHub:** [shennguyenrs/containers](https://github.com/shennguyenrs/containers)
