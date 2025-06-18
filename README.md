# Acme Widget Co. Basket System - Proof of Concept

This project is a proof-of-concept implementation of a shopping basket system for Acme Widget Co. It is built in pure Ruby with a primary focus on creating a system that is clean, maintainable, and architected for future growth.

## Core Architectural Principles

The solution is architected around modern, professional software design principles to ensure robustness and clarity.

-   **Immutability and Pure Functions:** The system is designed to be highly predictable by avoiding mutation and side effects. Business logic (like offer calculations) is handled by "pure" components that transform data rather than changing it in place.
-   **Separation of Concerns (Strategy Pattern):** The basket's core logic is completely decoupled from the specific business rules for pricing, delivery, and offers. This is achieved through the **Strategy Pattern**, where each rule is its own interchangeable object.
-   **Extensibility (Open/Closed Principle):** The system is designed to be easily extensible. New delivery rules or complex special offers can be added by creating new strategy classes without ever modifying the core `Basket` class.
-   **Financial Precision:** All monetary calculations are handled using Ruby's `BigDecimal` class to prevent floating-point inaccuracies and ensure financial robustness, as is required in any production system.

## How It Works: A Declarative, Non-Mutating Flow

The system avoids brittle `if/else` chains in favor of a declarative and non-mutating calculation flow, orchestrated by the `Basket`.

The key components are:

1.  **`Basket` (The Coordinator):** The central class. Its only responsibilities are to manage the list of `LineItem` objects and to orchestrate the calculation process by invoking its collaborators.

2.  **Offer Strategies (e.g., `BuyOneGetOneHalfPriceStrategy`):** These are discrete, stateless objects that receive the list of items and return a **Discount Ledger**—a simple hash that maps specific items to the discounts they are eligible for. They do not modify the basket's state.

3.  **Delivery Rules (e.g., `DeliveryRule`):** Delivery tiers are modeled as explicit, self-contained objects, each with a defined `range` and `cost`. This is a more robust and readable approach than magic-value hashes. The `TieredDeliveryStrategy` simply finds the first rule that applies.

The final calculation flow is:

`Add Items to Basket` -> `Strategies calculate Discount Ledgers` -> `Basket applies ledgers to get Net Subtotal` -> `Delivery Strategy calculates cost` -> **Final, Precise Total**

## Key Assumptions & Business Rule Interpretations

-   **"Buy One Get One Half Price" Offer:** This rule has been interpreted as a "for every pair" discount. For every two "Red Widgets" (`R01`) in the basket, one receives a 50% discount.
-   **Final Total Calculation:** The challenge examples indicate that final totals are **truncated** to two decimal places, not rounded. Our system achieves this with `BigDecimal#round(2, :truncate)` for financial accuracy.

## How to Run This Project

### 1. Clone the Repository

**HTTPS:**

```bash
git clone https://github.com/Sboursen/amce_basket.git
```

**SSH:**

```bash
git clone git@github.com:Sboursen/amce_basket.git
```

Then navigate into the directory:

```bash
cd amce_basket
```

### 2. Install Dependencies

**Prerequisites:**

-   **Ruby:** The required version is specified in the `.ruby-version` and `Gemfile`. We recommend using a version manager like `rbenv`, `rvm`, or `asdf` to install it automatically.
-   **Bundler:** (`gem install bundler`)

**Installation:**

```bash
bundle install
```

### 3. Check Code Quality

The project uses [RuboCop](https://rubocop.org/) to enforce a consistent code style.

```bash
bundle exec rubocop
```

### 4. Run the Test Suite

The project has a full test suite using RSpec, with both high-level integration tests that verify the system as a whole, and isolated unit tests for each strategy and component.

```bash
bundle exec rspec
```

### 5. See an Example in Action

A demonstration script is included to show how the system is used.

```bash
ruby main.rb
```

This will output the totals for the example baskets provided in the challenge.

