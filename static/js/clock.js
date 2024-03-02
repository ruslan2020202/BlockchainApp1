function updateClock() {
    var now = new Date();
    var hours = now.getHours();
    var minutes = now.getMinutes();
    var seconds = now.getSeconds();

    hours = hours < 10 ? '0' + hours : hours;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    seconds = seconds < 10 ? '0' + seconds : seconds;

    var timeString = hours + ':' + minutes + ':' + seconds;
    document.getElementById('clock').innerText = timeString;
}

updateClock(); // вызов функции для отображения времени при загрузке страницы

setInterval(updateClock, 1000); // вызов функции каждую секунду для обновления времени
