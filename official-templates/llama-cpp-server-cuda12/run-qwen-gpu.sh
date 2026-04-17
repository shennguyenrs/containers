#!/bin/sh
set -eu

export LD_LIBRARY_PATH="/app:/app/lib:/usr/local/lib:/usr/lib:/usr/lib64:${LD_LIBRARY_PATH:-}"

WORKSPACE_DIR="/workspace"
MODEL_DIR="$WORKSPACE_DIR/models"
MODEL_FILE="$MODEL_DIR/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf"
MODEL_URL="https://huggingface.co/HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive/resolve/main/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf"

mkdir -p "$MODEL_DIR"
cd "$WORKSPACE_DIR"

if [ ! -f "$MODEL_FILE" ]; then
	echo "--- Downloading Qwen 3.6 35B Model (~24GB) ---"
	wget -O "$MODEL_FILE" "$MODEL_URL"
else
	echo "--- Model already exists in /workspace/models, skipping download ---"
fi

echo "--- Starting Llama.cpp Server on port 8080 ---"
echo "--- Access via RunPod Proxy Port: 8081 ---"

exec /app/llama-server \
	-m "$MODEL_FILE" \
	--host 0.0.0.0 \
	--port 8080 \
	-c 204800 \
	-ngl 99 \
	-t 4 \
	-ub 1024 \
	-ctxcp 2 \
	-np 1 \
	--jinja \
	--chat-template-kwargs '{"enable_thinking": true,"preserve_thinking": true}' \
	--flash-attn auto \
	--cache-type-k q8_0 \
	--cache-type-v q8_0 \
	--batch-size 1024 \
	--temp 1.0 \
	--top-p 0.95 \
	--min-p 0 \
	--top-k 20 \
	--presence_penalty 1.5
