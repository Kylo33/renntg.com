---
title: "Intrinsic Motivation"
summary: |
    Understand how lazy segment trees work, and how to apply them to solve
    competitive programming problems.
pubDate: 2026-05-27
tags: ["Algorithms", "C++"]
---

Prerequisites: Segment Trees

# Introduction

Lazy segment trees have been a challenging technique for me to understand
and apply in my competitive programming journey. If you understand how
segment trees work, it isn't difficult to understand the concept of a lazy
segment tree. However, unlike segment trees whose templates are flexible
enough to be applied to a wide range of problems, there isn't a great
one-size-fits-all template for using lazy segment trees. Therefore, it is
important to get a strong understanding of how they work, and to practice
implementing a few on your own.

It was difficult for me to implement my first lazy segment trees, so I
hope to offer a roadmap, along with some pointers, to give you a head
start.

My understanding of lazy segment trees comes from
[cp-algorithms](https://cp-algorithms.com/data_structures/segment_tree.html#range-updates-lazy-propagation)
and the [Competitive Programmer's
Handbook](https://cses.fi/book/book.pdf). The ideas I share here come from
those resources, as well as my experience implementing lazy segment trees.

# Primer

Lazy segment trees allow you to perform range updates and range queries,
both in $\mathcal{O}(\log n)$ time. For example, you might decide to
create a lazy segment tree that supports a range addition update and a
range sum query.

In a regular segment tree, each node in the tree contains some metric
about the nodes in the range it represents. For a lazy segment tree, each
node contains a metric about the nodes in its range, along with an
optional lazy update (an operation that should be applied to its range,
but won't be applied until it is needed).

## Two Kinds

There are two main types of lazy segment trees: array-based trees, and
pointer-based trees. Each tree has a similar implementation (do not
worry), but knowing about each type will help you select one in your
problems.

- Array-based trees are faster, and more memory-efficient for trees with a
  small number of nodes because they avoid having to store pointers to
  children.
    - References to a node's children are implicit using the array's
      index. For a tree rooted at index $1$, the left child of a node $k$
      is $2k$, and the right child is $2k+1$.
- Pointer-based trees instead use a struct, or similar structure, that
  stores a pointer to that node's immediate children.
    - Since a pointer-based tree does not contain an underlying array, it
      can represent arrays that could not traditionally fit in memory
      (even lengths up to $10^9$).

As a rule of thumb, I choose to use pointer-based trees if I need to
represent a very large array (above $10^6$), and I choose an array-based
tree otherwise.

## What should be stored?

