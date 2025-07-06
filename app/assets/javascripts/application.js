// Simple Carousel functionality without imports
document.addEventListener('DOMContentLoaded', function() {
  const carousel = document.querySelector('[data-controller="carousel"]');
  if (!carousel) return;
  
  const slidesContainer = carousel.querySelector('[data-carousel-target="slides"]');
  const dots = carousel.querySelectorAll('[data-carousel-target="dot"]');
  const prevButton = carousel.querySelector('[data-action*="previous"]');
  const nextButton = carousel.querySelector('[data-action*="next"]');
  
  let currentSlide = 0;
  const totalSlides = slidesContainer.children.length;
  let autoAdvanceTimer;
  
  function updateCarousel() {
    const translateX = -currentSlide * 100;
    slidesContainer.style.transform = `translateX(${translateX}%)`;
    updateDots();
  }
  
  function updateDots() {
    dots.forEach((dot, index) => {
      if (index === currentSlide) {
        dot.classList.remove('bg-gray-300');
        dot.classList.add('bg-blue-600');
      } else {
        dot.classList.remove('bg-blue-600');
        dot.classList.add('bg-gray-300');
      }
    });
  }
  
  function nextSlide() {
    stopAutoAdvance();
    currentSlide = (currentSlide + 1) % totalSlides;
    updateCarousel();
    startAutoAdvance();
  }
  
  function previousSlide() {
    stopAutoAdvance();
    currentSlide = currentSlide === 0 ? totalSlides - 1 : currentSlide - 1;
    updateCarousel();
    startAutoAdvance();
  }
  
  function goToSlide(slideIndex) {
    stopAutoAdvance();
    currentSlide = slideIndex;
    updateCarousel();
    startAutoAdvance();
  }
  
  function startAutoAdvance() {
    if (totalSlides > 1) {
      autoAdvanceTimer = setInterval(nextSlide, 5000);
    }
  }
  
  function stopAutoAdvance() {
    if (autoAdvanceTimer) {
      clearInterval(autoAdvanceTimer);
      autoAdvanceTimer = null;
    }
  }
  
  // Event listeners
  if (nextButton) {
    nextButton.addEventListener('click', nextSlide);
  }
  
  if (prevButton) {
    prevButton.addEventListener('click', previousSlide);
  }
  
  dots.forEach((dot, index) => {
    dot.addEventListener('click', () => goToSlide(index));
  });
  
  // Initialize
  updateDots();
  startAutoAdvance();
});