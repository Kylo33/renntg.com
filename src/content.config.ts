import { defineCollection, z } from "astro:content";

import { glob } from "astro/loaders";

const projects = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/data/projects" }),
  schema: z.object({
    title: z.string(),
    pubDate: z.coerce.date(),
    tags: z.array(z.string()),
    link: z.string(),
  }),
});

// 4. Export a single `collections` object to register your collection(s)
export const collections = { projects };
