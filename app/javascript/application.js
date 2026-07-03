// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import React from "react"
import { createRoot } from "react-dom/client"
import FootDraftsApp from "./components/FootDraftsApp"

const mountFootDrafts = () => {
  const element = document.getElementById("footdrafts-app")
  if (!element) return

  const root = createRoot(element)
  root.render(React.createElement(FootDraftsApp))
}

document.addEventListener("turbo:load", mountFootDrafts)
