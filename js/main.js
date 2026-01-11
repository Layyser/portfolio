const menuToggle = document.querySelector(".menu-toggle")
const nav = document.querySelector("nav")
const navLinks = document.querySelectorAll("nav a")

menuToggle.addEventListener("click", () => {
  nav.classList.toggle("active")
  menuToggle.classList.toggle("active")
})

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

document.querySelectorAll(".section").forEach((section) => {
  section.style.opacity = "0"
  section.style.transform = "translateY(20px)"
  section.style.transition = "opacity 0.6s ease, transform 0.6s ease"
  observer.observe(section)
})


// Get the accent color
const accentHex = getComputedStyle(document.documentElement)
  .getPropertyValue('--accent')
  .trim()
  .replace('#', '');

// Convert to RGB
const r = parseInt(accentHex.substring(0, 2), 16);
const g = parseInt(accentHex.substring(2, 4), 16);
const b = parseInt(accentHex.substring(4, 6), 16);

// Set the computed properties
document.documentElement.style.setProperty('--accent2', `rgb(${r}, ${g}, ${b})`);
document.documentElement.style.setProperty('--accent2-transparent', `rgba(${r}, ${g}, ${b}, 0.2)`);