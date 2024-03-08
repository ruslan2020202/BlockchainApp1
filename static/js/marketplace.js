function timer(endTime, input) {
    endTime = Number(endTime)

    function updaterTime() {
        let currentTime = Number(String(Date.now()).slice(0, 10))
        let remainingTime = endTime - currentTime
        if (remainingTime <= 0) {
            clearInterval(timerInterval)
            //
        } else {
            let minutes = Math.floor(remainingTime / 60)
            let seconds = remainingTime % 60
            if (minutes < 10) {
                minutes = `0${minutes}`
            }
            if (seconds < 10) {
                seconds = `0${seconds}`
            }
            input.innerText = `${minutes}:${seconds}`
        }
    }

    let timerInterval = setInterval(updaterTime, 1000)
    updaterTime()
}

