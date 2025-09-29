#!/usr/bin/env python3
"""
Script to populate sample subscription/transaction data for testing the enhanced dashboard
"""

import sys
import os
sys.path.append(os.path.dirname(__file__))

from datetime import datetime, timedelta
import random
from decimal import Decimal
from sqlalchemy.orm import Session

from app.utils.database import get_db
from app.models.user import User
from app.models.category import Category, CategoryType
from app.models.transaction import Transaction

# Sample subscription services data
SAMPLE_SUBSCRIPTIONS = [
    {"name": "Giải trí", "category": "Entertainment", "amount": 2500000, "color": "#9C27B0"},
    {"name": "Thuế nhà", "category": "Utilities", "amount": 8500000, "color": "#2196F3"},
    {"name": "HD Nước", "category": "Utilities", "amount": 60000, "color": "#2196F3"},
    {"name": "HD Internet", "category": "Utilities", "amount": 250000, "color": "#2196F3"},
    {"name": "Xăng xe", "category": "Transportation", "amount": 1500000, "color": "#FF9800"},
    {"name": "Ăn uống", "category": "Health & Fitness", "amount": 5000000, "color": "#F44336"},
    {"name": "Đồ dùng em bé", "category": "Shopping", "amount": 6000000, "color": "#E91E63"},
    {"name": "HD Điện", "category": "Utilities", "amount": 1200000, "color": "#2196F3"},
    {"name": "Tráng trẻ", "category": "Health & Fitness", "amount": 5320000, "color": "#F44336"},
    {"name": "Phát sinh khác", "category": "Shopping", "amount": 3000000, "color": "#E91E63"},
    {"name": "BH xe oto", "category": "Transportation", "amount": 6000000, "color": "#FF9800"},
    {"name": "Netflix", "category": "Entertainment", "amount": 180000, "color": "#9C27B0"},
    {"name": "Spotify", "category": "Entertainment", "amount": 60000, "color": "#9C27B0"},
    {"name": "Adobe Creative Suite", "category": "Software", "amount": 520000, "color": "#673AB7"},
    {"name": "Gym Membership", "category": "Health & Fitness", "amount": 800000, "color": "#F44336"},
]

def create_sample_categories(db: Session, user_id: int):
    """Create sample categories if they don't exist"""
    category_data = [
        {"name": "Entertainment", "type": CategoryType.EXPENSE, "color": "#9C27B0"},
        {"name": "Utilities", "type": CategoryType.EXPENSE, "color": "#2196F3"},
        {"name": "Transportation", "type": CategoryType.EXPENSE, "color": "#FF9800"},
        {"name": "Health & Fitness", "type": CategoryType.EXPENSE, "color": "#F44336"},
        {"name": "Shopping", "type": CategoryType.EXPENSE, "color": "#E91E63"},
        {"name": "Software", "type": CategoryType.EXPENSE, "color": "#673AB7"},
        {"name": "Food & Dining", "type": CategoryType.EXPENSE, "color": "#4CAF50"},
        {"name": "Salary", "type": CategoryType.INCOME, "color": "#8BC34A"},
    ]

    categories = {}
    for cat_data in category_data:
        category = db.query(Category).filter(
            Category.user_id == user_id,
            Category.name == cat_data["name"]
        ).first()

        if not category:
            category = Category(
                user_id=user_id,
                name=cat_data["name"],
                type=cat_data["type"],
                color=cat_data["color"]
            )
            db.add(category)
            db.commit()
            db.refresh(category)

        categories[cat_data["name"]] = category

    return categories

def create_sample_transactions(db: Session, user_id: int, categories: dict):
    """Create sample subscription transactions"""
    base_date = datetime.now()

    # Clear existing transactions for this user
    db.query(Transaction).filter(Transaction.user_id == user_id).delete()

    transactions = []

    # Create monthly subscription transactions
    for i, sub in enumerate(SAMPLE_SUBSCRIPTIONS):
        # Create transactions for last 3 months and next month
        for month_offset in range(-3, 2):
            transaction_date = base_date + timedelta(days=30 * month_offset + random.randint(-5, 5))

            # Find matching category
            category = None
            for cat_name, cat_obj in categories.items():
                if cat_name == sub["category"]:
                    category = cat_obj
                    break

            if not category:
                # Default to first expense category
                category = next(cat for cat in categories.values()
                              if cat.type == CategoryType.EXPENSE)

            transaction = Transaction(
                user_id=user_id,
                description=sub["name"],
                amount=Decimal(str(sub["amount"])),
                transaction_date=transaction_date,
                category_id=category.id,
                notes=f"Monthly subscription for {sub['name']}"
            )
            transactions.append(transaction)

    # Add some income transactions
    salary_category = categories.get("Salary")
    if salary_category:
        for month_offset in range(-3, 1):
            transaction_date = base_date + timedelta(days=30 * month_offset + random.randint(1, 28))

            transaction = Transaction(
                user_id=user_id,
                description="Monthly Salary",
                amount=Decimal("50000000"),  # 50M VND
                transaction_date=transaction_date,
                category_id=salary_category.id,
                notes="Monthly salary payment"
            )
            transactions.append(transaction)

    # Add all transactions
    db.add_all(transactions)
    db.commit()

    print(f"Created {len(transactions)} sample transactions")

def main():
    """Main function to populate sample data"""
    # Get database session
    db_gen = get_db()
    db = next(db_gen)

    try:
        # Get the first user (or create a test user)
        user = db.query(User).first()

        if not user:
            print("No users found. Please register a user first.")
            return

        print(f"Populating data for user: {user.email}")

        # Create categories
        categories = create_sample_categories(db, user.id)
        print(f"Created/found {len(categories)} categories")

        # Create transactions
        create_sample_transactions(db, user.id, categories)

        print("Sample data population completed successfully!")

    except Exception as e:
        print(f"Error populating sample data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    main()