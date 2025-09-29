from sqlalchemy.orm import Session
from ..models.category import Category, CategoryType

def create_default_categories(db: Session, user_id: int):
    """Create default categories for a new user"""
    default_categories = [
        # Income categories
        {"name": "Salary", "type": CategoryType.INCOME, "color": "#4CAF50", "icon": "💰"},
        {"name": "Freelance", "type": CategoryType.INCOME, "color": "#2196F3", "icon": "💻"},
        {"name": "Investment", "type": CategoryType.INCOME, "color": "#FF9800", "icon": "📈"},

        # Expense categories
        {"name": "Food & Dining", "type": CategoryType.EXPENSE, "color": "#F44336", "icon": "🍽️"},
        {"name": "Transportation", "type": CategoryType.EXPENSE, "color": "#9C27B0", "icon": "🚗"},
        {"name": "Shopping", "type": CategoryType.EXPENSE, "color": "#E91E63", "icon": "🛍️"},
        {"name": "Entertainment", "type": CategoryType.EXPENSE, "color": "#FF5722", "icon": "🎬"},
        {"name": "Bills & Utilities", "type": CategoryType.EXPENSE, "color": "#607D8B", "icon": "⚡"},
        {"name": "Healthcare", "type": CategoryType.EXPENSE, "color": "#009688", "icon": "🏥"},
        {"name": "Education", "type": CategoryType.EXPENSE, "color": "#3F51B5", "icon": "📚"},
    ]

    categories = []
    for cat_data in default_categories:
        category = Category(**cat_data, user_id=user_id)
        categories.append(category)

    db.add_all(categories)
    db.commit()

    return categories