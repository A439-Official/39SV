local task = {
    running = false,
    items = {},
    index = 1,
    batchSize = 1,
    total = 0,
    processor = nil,
    onComplete = nil,
    onProgress = nil,
    cancelled = false,
    targetFrameTime = 1 / 60,
    minBatch = 1,
    maxBatch = 1000
}

function async_run(items, processor, onComplete, onProgress)
    if task.running then
        return false
    end
    task.running = true
    task.items = items
    task.total = #items
    task.index = 1
    task.batchSize = 1
    task.processor = processor
    task.onComplete = onComplete
    task.onProgress = onProgress
    task.cancelled = false
    return true
end

function async_process()
    if not task.running or task.cancelled then
        if task.running then
            task.running = false
        end
        return true
    end

    local start = os.clock()
    local remaining = task.total - task.index + 1
    local limit = math.min(task.batchSize, remaining)

    for i = 1, limit do
        local idx = task.index + i - 1
        task.processor(task.items[idx], idx, task.total)
    end
    task.index = task.index + limit

    local elapsed = os.clock() - start
    if elapsed > 0 then
        local ratio = task.targetFrameTime / elapsed
        if ratio > 1.5 then
            task.batchSize = math.min(task.maxBatch, math.ceil(task.batchSize * 1.5))
        elseif ratio < 0.5 then
            task.batchSize = math.max(task.minBatch, math.ceil(task.batchSize * 0.5))
        end
    end

    if task.onProgress then
        task.onProgress(task.index - 1, task.total)
    end

    if task.index > task.total then
        task.running = false
        if task.onComplete then
            task.onComplete()
        end
        return true
    end
    return false
end

function async_is_running()
    return task.running
end

function async_cancel()
    if task.running then
        task.cancelled = true
    end
end

function async_get_progress()
    return task.total == 0 and 0 or (task.index - 1) / task.total
end

function async_get_progress_text()
    return task.running and (task.index - 1 .. " / " .. task.total) or ""
end
