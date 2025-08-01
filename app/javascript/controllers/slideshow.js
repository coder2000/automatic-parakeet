document.addEventListener("DOMContentLoaded", function() {
    const container = document.querySelector('.SlideShow');
    if (!container) {
        // close the script if the container doesn't exist
        return;
    }
    const slides = container.querySelectorAll('.slide_preview');
    const indicators = document.querySelectorAll('.indicator');
    const slideInterval = 5000; // Timing
    let currentIndex = 0;
    let intervalId;

    function scrollToNextSlide() {
        currentIndex = (currentIndex + 1) % slides.length;
        updateSlidePosition();
    }

    function goToSlide(index) {
        currentIndex = index;
        updateSlidePosition();
        stopSlideShow();
        startSlideShow();
    }

    function updateSlidePosition() {
        container.scrollTo({
            left: slides[currentIndex].offsetLeft - container.offsetLeft,
            behavior: 'smooth'
        });
        updateIndicators();
    }

    function updateIndicators() {
        indicators.forEach((indicator, index) => {
            indicator.classList.toggle('active', index === currentIndex);
        });
    }

    function startSlideShow() {
        intervalId = setInterval(scrollToNextSlide, slideInterval);
    }

    function stopSlideShow() {
        clearInterval(intervalId);
    }

    slides.forEach(slide => {
        slide.addEventListener('mouseover', stopSlideShow);
        slide.addEventListener('mouseout', startSlideShow);
    });

    indicators.forEach((indicator, index) => {
        indicator.addEventListener('mouseover', () => goToSlide(index));
    });

    startSlideShow();
});
