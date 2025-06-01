// script.js

// Display current time and update every second
function updateTime() {
    const currentTimeElement = document.getElementById('currentTime');
    const now = new Date();
    currentTimeElement.textContent = now.toLocaleTimeString('en-GB', { hour12: false });
}
setInterval(updateTime, 1000);
updateTime();

// Modal control
function showModal(id) {
    document.getElementById(id).classList.add('active');
}

function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}

// Modal trigger functions
function showFlagModal() {
    showModal('flagModal');
}

function showUnflagModal() {
    showModal('unflagModal');
}

function showSearchModal() {
    showModal('searchModal');
}

// Dummy deployment function
function deployCamera() {
    alert('Deploying ANPR camera unit...');
}

// Handle flagging vehicle
function flagVehicle() {
    const plate = document.getElementById('flagPlate').value.trim().toUpperCase();
    const reason = document.getElementById('flagReason').value;
    const priority = document.getElementById('flagPriority').value;
    const notes = document.getElementById('flagNotes').value.trim();

    if (!plate || !reason || !priority) {
        return alert('Please complete all required fields.');
    }

    // Send data to server via NUI or handle client-side
    console.log('Flagging vehicle:', { plate, reason, priority, notes });

    closeModal('flagModal');
}

// Handle unflagging vehicle
function unflagVehicle() {
    const plate = document.getElementById('unflagPlate').value.trim().toUpperCase();

    if (!plate) {
        return alert('Please enter a plate to unflag.');
    }

    // Send data to server via NUI or handle client-side
    console.log('Unflagging vehicle:', plate);

    closeModal('unflagModal');
}

// Handle search
function searchVehicle() {
    const plate = document.getElementById('searchPlate').value.trim().toUpperCase();

    if (!plate) {
        return alert('Please enter a registration number.');
    }

    // Send search request to server or use static response
    console.log('Searching for vehicle:', plate);

    closeModal('searchModal');
}

// Close the entire UI
function closeUI() {
    const ui = document.querySelector('.container');
    if (ui) {
        ui.style.display = 'none';
    }
    
    // Close any open modals
    document.querySelectorAll('.modal.active').forEach(modal => {
        modal.classList.remove('active');
    });

    // FiveM NUI focus reset (only if available)
    if (typeof SetNuiFocus === 'function') {
        SetNuiFocus(false, false);
    }
}

// Close UI on ESC key press
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeUI();
    }
});

// Expose functions globally for onclick handlers
window.showFlagModal = showFlagModal;
window.showUnflagModal = showUnflagModal;
window.showSearchModal = showSearchModal;
window.deployCamera = deployCamera;
window.flagVehicle = flagVehicle;
window.unflagVehicle = unflagVehicle;
window.searchVehicle = searchVehicle;
window.closeModal = closeModal;
window.closeUI = closeUI;
