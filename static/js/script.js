let file = document.getElementById('formFile')
const fromty = document.querySelector("#input-image")
let amount
file.addEventListener('change', function () {
    let imgIn = document.querySelector("img")
    console.log(file.value)
    try {
        if (imgIn) {
            fromty.removeChild(imgIn)
        }
    } catch (err) {
        fromty.removeChild(imgIn)
    }
    if (file.value !== '') {
        let img = document.createElement("img")
        let imgdata = file.value.split('\\')
        img.src = `static/${imgdata[2]}`
        img.width = 300
        img.height = 200
        img.setAttribute('name', 'imageName')
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