// Blood Donor Finder - Client-side interactions

document.addEventListener("DOMContentLoaded", function () {
    // Initialize Tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Client-side Form Validation for Registration Form
    const donorForm = document.getElementById("donorForm");
    if (donorForm) {
        donorForm.addEventListener("submit", function (e) {
            let isValid = true;

            const phoneInput = donorForm.querySelector('input[name="phone"]');
            if (phoneInput && !/^\d{10}$/.test(phoneInput.value.trim())) {
                phoneInput.classList.add("is-invalid");
                isValid = false;
            } else if (phoneInput) {
                phoneInput.classList.remove("is-invalid");
            }

            const ageInput = donorForm.querySelector('input[name="age"]');
            if (ageInput) {
                const age = parseInt(ageInput.value, 10);
                if (isNaN(age) || age < 18 || age > 65) {
                    ageInput.classList.add("is-invalid");
                    isValid = false;
                } else {
                    ageInput.classList.remove("is-invalid");
                }
            }

            const pledgeCheck = document.getElementById("pledgeCheck");
            if (pledgeCheck && !pledgeCheck.checked) {
                pledgeCheck.classList.add("is-invalid");
                isValid = false;
            } else if (pledgeCheck) {
                pledgeCheck.classList.remove("is-invalid");
            }

            if (!isValid) {
                e.preventDefault();
                e.stopPropagation();
            }
        });
    }

    // Interactive Compatibility Tool (if on /compatibility page)
    const compatButtons = document.querySelectorAll(".blood-selector-btn");
    const donateContainer = document.getElementById("donate-to-badges");
    const receiveContainer = document.getElementById("receive-from-badges");
    const searchCompatBtn = document.getElementById("search-compat-btn");

    if (compatButtons.length > 0 && typeof DONOR_MATRIX !== "undefined" && typeof RECIPIENT_MATRIX !== "undefined") {
        function updateCompatibilityView(bg) {
            // Update active button state
            compatButtons.forEach(btn => {
                if (btn.getAttribute("data-bg") === bg) {
                    btn.classList.add("btn-danger", "text-white");
                    btn.classList.remove("btn-outline-danger");
                } else {
                    btn.classList.remove("btn-danger", "text-white");
                    btn.classList.add("btn-outline-danger");
                }
            });

            // Update Can Donate To
            const recipients = DONOR_MATRIX[bg] || [];
            donateContainer.innerHTML = recipients.map(item => 
                `<span class="badge bg-success fs-6 px-3 py-2 rounded-pill shadow-sm"><i class="fa-solid fa-check me-1"></i> ${item}</span>`
            ).join("");

            // Update Can Receive From
            const donors = RECIPIENT_MATRIX[bg] || [];
            receiveContainer.innerHTML = donors.map(item => 
                `<span class="badge bg-primary fs-6 px-3 py-2 rounded-pill shadow-sm"><i class="fa-solid fa-heart me-1"></i> ${item}</span>`
            ).join("");

            // Update the link to donors search
            if (searchCompatBtn) {
                searchCompatBtn.href = `/donors?blood_group=${encodeURIComponent(bg)}&compatible=1`;
                searchCompatBtn.innerHTML = `<i class="fa-solid fa-magnifying-glass me-1"></i> Find Matching Donors for ${bg}`;
            }
        }

        // Attach click listener
        compatButtons.forEach(btn => {
            btn.addEventListener("click", function () {
                const bg = this.getAttribute("data-bg");
                updateCompatibilityView(bg);
            });
        });

        // Initialize with default O+
        updateCompatibilityView("O+");
    }
});
