let file = document.getElementById('formFile')
const fromty = document.querySelector("#input-image")
file.addEventListener('change', function () {
    let imgIn = document.querySelector("#imageName")
    console.log(file.value)
    if (imgIn) {
        fromty.removeChild(imgIn)
    }
    if (file.value !== '') {
        let img = document.createElement("img")
        let imgdata = file.value.split('\\')
        img.src = `static/image/${imgdata[2]}`
        img.width = 300
        img.height = 200
        img.setAttribute('id', 'imageName')
        fromty.appendChild(img)
    }

})

// let range = document.querySelector('#formRange')
let range = document.querySelector("#formRange")

let rangeLabel = document.querySelector('#rangeId')
rangeLabel.textContent = `Количество: ${range.value}`
range.addEventListener('change', () => {
    rangeLabel.textContent = `Количество: ${range.value}`
})