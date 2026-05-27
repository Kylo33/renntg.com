import { defineCollection, z } from "astro:content";

import { glob } from "astro/loaders";

const blog = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/data/blog" }),
  schema: z.object({
      title: z.string(),
      summary: z.string(),
      pubDate: z.coerce.date(),
      tags: z.array(z.string()),
  })
})

const projects = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/data/projects" }),
  schema: z.object({
    title: z.string(),
    pubDate: z.coerce.date(),
    tags: z.array(z.string()),
    link: z.string(),
    hidden: z.boolean().default(false),
  }),
});

export const collections = { blog, projects };
