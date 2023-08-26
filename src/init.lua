local coroutine_wrap = coroutine.wrap

local Sandwich = {}

Sandwich.Distributer = function (instructions, ...)
    coroutine_wrap(instructions)(...)
end

function Sandwich.schedule()
	local schedule = {
        job_dependencies = {},
		jobs = {},
	}

	function schedule.job(job_instructions, ...)
		schedule.job_dependencies[job_instructions] = {...}
        table.insert(schedule.jobs, job_instructions)

		return job_instructions
	end

    function schedule.start(...)
        local job_dependencies = schedule.job_dependencies

        local _incomplete_job_threads_list = {}
        local _incomplete_job_threads_index = {}

        local _completed_jobs = {}

        -- local before = schedule.before
        -- local after = schedule.after

        local function job_run(job, ...)
            local _this_job_dependencies = job_dependencies[job]
            local _completed_dependencies = 0

            local _can_proceed = _completed_dependencies == #_this_job_dependencies

            while not _can_proceed do
                _completed_dependencies = 0

                for _, _o_job in ipairs(_this_job_dependencies) do
                    if not _completed_jobs[_o_job] then break end

                    _completed_dependencies = _completed_dependencies + 1
                end


                _can_proceed = _completed_dependencies == #_this_job_dependencies

                coroutine.yield()
            end

            Sandwich.Distributer(job, ...)

            local _last_job = _incomplete_job_threads_list[#_incomplete_job_threads_list]
            _incomplete_job_threads_list[_incomplete_job_threads_index[job]] = _last_job
            _incomplete_job_threads_list[#_incomplete_job_threads_list] = nil

            _incomplete_job_threads_index[_last_job.Job] = _incomplete_job_threads_index[job]
            _incomplete_job_threads_index[job] = nil

            _completed_jobs[job] = true
        end

		for _, job in ipairs(schedule.jobs) do
            local _thread = coroutine_wrap(job_run)

            table.insert(_incomplete_job_threads_list, {
                Thread = _thread,
                Job = job
            })

            _incomplete_job_threads_index[job] = #_incomplete_job_threads_list

            _thread(job, ...)
		end

        local i;

        while #_incomplete_job_threads_list > 0 do
            i = 1

            while _incomplete_job_threads_list[i] do
                _incomplete_job_threads_list[i].Thread()

                i = i + 1
            end
        end
	end

	return schedule
end

-- TODO: Modify
function Sandwich.interval(seconds, callback, ...)
	return task.spawn(function(...)
		repeat
			task.wait(seconds)
		until callback(...)
	end, ...)
end

return Sandwich


