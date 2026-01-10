// --- NEW: Mobile Menu Logic ---
const menuToggle = document.querySelector(".menu-toggle")
const nav = document.querySelector("nav")
const navLinks = document.querySelectorAll("nav a")

// Toggle menu on click
menuToggle.addEventListener("click", () => {
  nav.classList.toggle("active")
  menuToggle.classList.toggle("active")
})

// Close menu when a link is clicked
navLinks.forEach(link => {
  link.addEventListener("click", () => {
    nav.classList.remove("active")
    menuToggle.classList.remove("active")
  })
})

let resizeTimer
window.addEventListener("resize", () => {
  document.body.classList.add("resize-animation-stopper")
  clearTimeout(resizeTimer)
  resizeTimer = setTimeout(() => {
    document.body.classList.remove("resize-animation-stopper")
  }, 400)
})
// ------------------------------

// Simple smooth scroll for nav links
document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
  anchor.addEventListener("click", function (e) {
    e.preventDefault()
    const target = document.querySelector(this.getAttribute("href"))
    if (target) {
      target.scrollIntoView({
        behavior: "smooth",
        block: "start",
      })
    }
  })
})

// Fade in sections on scroll
const observerOptions = {
  root: null,
  rootMargin: "0px",
  threshold: 0.1,
}

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.style.opacity = "1"
      entry.target.style.transform = "translateY(0)"
    }
  })
}, observerOptions)

// Apply initial styles and observe sections
document.querySelectorAll(".section").forEach((section) => {
  section.style.opacity = "0"
  section.style.transform = "translateY(20px)"
  section.style.transition = "opacity 0.6s ease, transform 0.6s ease"
  observer.observe(section)
})

// Header scroll effect
let lastScroll = 0
const header = document.querySelector("header")

window.addEventListener("scroll", () => {
  const currentScroll = window.pageYOffset

  // Only apply background logic if menu is NOT open (prevents visual glitches)
  if (!nav.classList.contains("active")) {
      if (currentScroll > 100) {
        header.style.background = "rgba(10, 10, 10, 0.9)"
        header.style.backdropFilter = "blur(10px)"
        header.style.padding = "1rem 2rem"
        header.style.margin = "0 -2rem"
        header.style.width = "calc(100% + 4rem)"
      } else {
        header.style.background = "transparent"
        header.style.backdropFilter = "none"
        header.style.padding = "0"
        header.style.margin = "0"
        header.style.width = "auto"
      }
  }

  lastScroll = currentScroll
})