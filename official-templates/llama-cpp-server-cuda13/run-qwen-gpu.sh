#!/usr/bin/env bash
set -eu

export LD_LIBRARY_PATH="/app:/app/lib:/usr/local/lib:/usr/lib:/usr/lib64:${LD_LIBRARY_PATH:-}"

WORKSPACE_DIR="/workspace"
MODEL_DIR="$WORKSPACE_DIR/models"
MODEL_FILE="$MODEL_DIR/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf"
MODEL_URL="https://huggingface.co/HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive/resolve/main/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf"
VISION_MMPROJ_FILE="$MODEL_DIR/mmproj-Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-f16.gguf"
VISION_MMPROJ_URL="https://huggingface.co/HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive/resolve/main/mmproj-Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-f16.gguf"

download_file() {
  local url="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"
  local filename
  filename="$(basename "$dest")"

  if [[ "$url" =~ ^https://huggingface.co/([^/]+)/([^/]+)/(resolve|blob)/([^/]+)/(.*)$ ]]; then
    local repo="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    local revision="${BASH_REMATCH[4]}"
    local repo_path="${BASH_REMATCH[5]%%\?*}"

    if command -v hf >/dev/null 2>&1; then
      echo "Downloading $filename via hf..."
      local temp_dir
      temp_dir=$(mktemp -d "${dest_dir}/.hf_tempXXXXXX")
      if hf download "$repo" "$repo_path" --revision "$revision" --local-dir "$temp_dir"; then
        mv "$temp_dir/$repo_path" "$dest"
        rm -rf "$temp_dir"
        return 0
      fi
      rm -rf "$temp_dir"
      echo "hf download failed, falling back to wget..."
    elif command -v huggingface-cli >/dev/null 2>&1; then
      echo "Downloading $filename via huggingface-cli..."
      local temp_dir
      temp_dir=$(mktemp -d "${dest_dir}/.hf_tempXXXXXX")
      if huggingface-cli download "$repo" "$repo_path" --revision "$revision" --local-dir "$temp_dir"; then
        mv "$temp_dir/$repo_path" "$dest"
        rm -rf "$temp_dir"
        return 0
      fi
      rm -rf "$temp_dir"
      echo "huggingface-cli download failed, falling back to wget..."
    fi
  fi

  echo "Downloading $filename via wget..."
  wget -O "$dest" "$url"
}

mkdir -p "$MODEL_DIR"
cd "$WORKSPACE_DIR"

if [ ! -f "$MODEL_FILE" ] || [ ! -f "$VISION_MMPROJ_FILE" ]; then
  echo "--- Downloading Qwen 3.6 35B Model + vision (~24GB) ---"
  if [ ! -f "$MODEL_FILE" ]; then
    download_file "$MODEL_URL" "$MODEL_FILE"
  fi
  if [ ! -f "$VISION_MMPROJ_FILE" ]; then
    download_file "$VISION_MMPROJ_URL" "$VISION_MMPROJ_FILE"
  fi
else
  echo "--- Models already exist in /workspace/models, skipping download ---"
fi

echo "--- Starting Llama.cpp Server on port 8080 ---"
echo "--- Access via RunPod Proxy Port: 8081 ---"

exec /app/llama-server \
  -m "$MODEL_FILE" \
  --mmproj "$VISION_MMPROJ_FILE" \
  --no-mmproj-offload \
  --host 0.0.0.0 \
  --port 8080 \
  -c 204800 \
  -ngl 99 \
  --jinja \
  --alias qwen3.6-35b-q4km
