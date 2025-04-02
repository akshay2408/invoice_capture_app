// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

  document.addEventListener("DOMContentLoaded", function () {
    window.openCamera = openCamera;
    window.capturePhoto = capturePhoto;
   
    // Handle tab clicks
    document.querySelectorAll('.nav-link').forEach((tab) => {
      tab.addEventListener('click', () => {
        console.log('Tab clicked:', tab);
        let tabId = tab.getAttribute('href').substring(1); // Remove the '#' from href
        document.querySelectorAll('.tab-pane').forEach((pane) => {
          if (pane.id === tabId) {
            pane.classList.add('show', 'active'); // Show active tab
          } else {
            pane.classList.remove('show', 'active'); // Hide non-active tabs
          }
        });
      });
    });
  });

  function openCamera() {
    navigator.mediaDevices.getUserMedia({ video: true })
      .then(stream => {
        const videoElement = document.getElementById("video");
        if (!videoElement) return;
        videoElement.srcObject = stream;
        videoElement.play();
        document.getElementById("cameraContainer").classList.remove("d-none");
        window.videoStream = stream;
      })
      .catch(() => alert("Camera access denied or unavailable. Please check permissions."));
  }

  function capturePhoto() {
    const video = document.getElementById("video");
    if (!video?.videoWidth) return;

    const canvas = document.createElement("canvas");
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext("2d").drawImage(video, 0, 0, canvas.width, canvas.height);

    document.getElementById("photo").src = canvas.toDataURL("image/png");
    document.getElementById("imageData").value = canvas.toDataURL("image/png");
    document.getElementById("photo").classList.remove("d-none");
    document.getElementById("cameraContainer").classList.add("d-none");

    window.videoStream?.getTracks().forEach(track => track.stop());
    window.videoStream = null;
  }
