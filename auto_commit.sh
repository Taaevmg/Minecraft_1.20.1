#!/bin/bash
# auto_commit.sh - Авто-коммит Minecraft сервера
# Расположен прямо в папке сервера!

echo "$(date '+%Y-%m-%d %H:%M:%S') - Начинаем авто-коммит..."

# 1. Удаляем session.lock (если сервер не запущен)
if [ -f "world/session.lock" ]; then
    echo "Удаляем session.lock..."
    rm -f world/session.lock
fi

# 2. Добавляем изменения в git (игнорируем ошибки)
git add --all --ignore-errors 2>/dev/null

# 3. Создаем коммит
COMMIT_MSG="Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
if git commit -m "$COMMIT_MSG" --allow-empty 2>/dev/null; then
    echo "✓ Коммит создан: $COMMIT_MSG"
else
    echo "⚠ Не удалось создать коммит"
fi

# 4. Пушим на GitHub (если настроено)
if git remote -v | grep -q "origin"; then
    echo "Отправляем на GitHub..."
    git push origin main 2>/dev/null && echo "✓ Отправлено на GitHub" || echo "⚠ Не удалось отправить"
fi

# 5. Логируем
echo "$(date '+%Y-%m-%d %H:%M:%S') - Готово!" >> backup.log
echo "✓ Завершено!"
