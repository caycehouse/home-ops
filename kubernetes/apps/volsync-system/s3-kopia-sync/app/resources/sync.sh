#!/bin/bash

set -euo pipefail

echo "=== Starting Kopia Sync to S3 ==="
echo "Target bucket: ${S3_BUCKET}"
echo
echo "Sync progress:"

kopia repository sync-to s3 \
    --endpoint="${S3_ENDPOINT}" \
    --bucket="${S3_BUCKET}" \
    --access-key="${S3_ACCESS_KEY_ID}" \
    --secret-access-key="${S3_SECRET_ACCESS_KEY}" \
    --delete \
    --parallel=8 </dev/null \
|| {
    echo
    echo "ERROR: Kopia sync failed"
    exit 1
}

echo
echo "=== Sync Operation Complete ==="
echo "Repository sync completed successfully at: $(date)"
