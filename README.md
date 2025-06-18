# Acme Widget Co. Basket System - Proof of Concept

This project is a proof-of-concept implementation of a shopping basket system for Acme Widget Co., built as a coding challenge submission.

## Core Design Philosophy

The solution is built in pure Ruby with a primary focus on creating a system that is clean, maintainable, and ready for future growth. The core principles guiding the architecture are:

- **Separation of Concerns:** The basket's core logic is completely decoupled from the specific business rules for pricing, delivery, and offers.
- **Extensibility (Open/Closed Principle):** The system is designed to be easily extensible. New delivery rules or complex special offers can be added by creating new "strategy" classes, without ever modifying the core `Basket` class.
- **Clarity and Testability:** The code is structured into small, single-responsibility classes that are easy to understand, test in isolation, and reason about.

## How It Works: The Strategy Pattern

To achieve the design goals, the system is architected around the **Strategy Pattern**, using **Dependency Injection** to wire the components together.

This approach avoids brittle, hard-to-maintain conditional logic (`if/else` chains) and results in a flexible and declarative system.

The key components are:

1.  **`Basket` (The Coordinator):** The central class. Its only responsibilities are to manage the list of items and to orchestrate the calculation process by invoking its collaborators. It is initialized with a product catalogue and a set of strategy objects.

2.  **Offer Strategies (e.g., `BuyOneGetOneHalfPriceStrategy`):** These are discrete objects responsible for a single job: applying a specific discount to a set of basket items. The `Basket` is configured with an array of these strategies. To add a new offer to the system, a developer simply creates a new strategy class and adds it to the configuration.

3.  **Delivery Strategy (e.g., `TieredDeliveryStrategy`):** This is another type of strategy object. Its sole responsibility is to calculate the delivery cost based on the post-offer subtotal. This isolates the delivery fee logic, making it easy to change the tiers or introduce new delivery methods in the future.

The final calculation flow is:
`Items` -> `Build Line Items` -> `Apply Offer Strategies` -> `Calculate Post-Offer Subtotal` -> `Apply Delivery Strategy` -> `Final Total`

## Key Assumptions & Business Rule Interpretations

- **"Buy One Get One Half Price" Offer:** This rule has been interpreted as a "for every pair" discount. For every two "Red Widgets" (`R01`) in the basket, one receives a 50% discount.
- **Currency Handling & Precision:** The example totals indicate that final totals are **truncated** to two decimal places, not rounded. This is handled via the `Float#truncate` method. For a production system, this would be handled using the `BigDecimal` class or an integer-based approach (storing cents).

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
-   **Ruby:** The required version is specified in the `.ruby-version` and `Gemfile`. We recommend using a version manager like `rbenv`, `rvm`, or `mise` to install it automatically.
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

The project has a full test suite using RSpec, with both high-level integration tests and isolated unit tests for each strategy.

```bash
bundle exec rspec
```

### 5. See an Example in Action

A demonstration script is included to show how the system is used.

```bash
ruby main.rb
```

This will output the totals for the example baskets provided in the challenge.
