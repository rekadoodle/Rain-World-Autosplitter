console.log("SCRIPt LOADFED");
if (rooms === undefined || rooms.length == 0) {
    var rooms = [];
    document.body.addEventListener('click', function() {
        document.querySelectorAll('.rw-text.room-labels').forEach(function(element) {
            rooms.indexOf(element.innerText) === -1 && rooms.push(element.innerText);
        });  
        console.log(rooms);
    }, true); 
    console.log("click defined");
}