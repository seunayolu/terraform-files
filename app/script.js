document.getElementById('contactForm').addEventListener('submit', function(event) {
    event.preventDefault();

    let formData = new FormData(this);

    fetch('process.php', {
        method: 'POST',
        body: formData
    })
    .then(response => response.text())
    .then(data => {
        alert(data);
        if (data === "Message sent successfully!") {
            document.getElementById('contactForm').reset();
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
});