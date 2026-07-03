import React from "react"

export default function FootDraftsApp() {
  return (
    <main className="mx-auto max-w-3xl p-6">
      <h1 className="text-3xl font-bold">FootDrafts</h1>
      <p className="mt-3 text-base text-gray-700">
        Draft football players online or offline without seeing their ratings.
      </p>
      <section className="mt-6 rounded-lg border border-gray-200 p-4">
        <h2 className="text-xl font-semibold">Boilerplate status</h2>
        <ul className="mt-2 list-disc space-y-1 pl-5 text-gray-700">
          <li>Ruby on Rails backend scaffolded</li>
          <li>React frontend integrated</li>
          <li>Ready for competition, player, and draft features</li>
        </ul>
      </section>
    </main>
  )
}
