#!/usr/bin/env python3
"""
Generate a sample ZKB (Zürcher Kantonalbank) statement PDF for testing ZüriBudget app.

Requirements:
    pip install reportlab

Usage:
    python3 generate_sample_zkb_statement.py
"""

from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.lib.units import mm
from datetime import datetime, timedelta
import random

def create_zkb_statement(filename="ZKB_Sample_Statement_January_2026.pdf"):
    """Create a realistic ZKB statement PDF with Swiss formatting"""

    c = canvas.Canvas(filename, pagesize=A4)
    width, height = A4

    # Swiss-style header
    c.setFont("Helvetica-Bold", 18)
    c.drawString(40, height - 60, "Zürcher Kantonalbank")

    c.setFont("Helvetica", 10)
    c.drawString(40, height - 80, "Bahnhofstrasse 9")
    c.drawString(40, height - 95, "8001 Zürich")

    # Account info
    c.setFont("Helvetica-Bold", 12)
    c.drawString(40, height - 130, "Kontoauszug / Account Statement")

    c.setFont("Helvetica", 10)
    c.drawString(40, height - 150, f"Konto / Account: CH93 0070 0110 0012 3456 7")
    c.drawString(40, height - 165, f"Periode / Period: 01.01.2026 - 31.01.2026")
    c.drawString(40, height - 180, f"Erstellt / Created: {datetime.now().strftime('%d.%m.%Y')}")

    # Customer info (right side)
    c.drawString(width - 200, height - 150, "Max Mustermann")
    c.drawString(width - 200, height - 165, "Musterstrasse 123")
    c.drawString(width - 200, height - 180, "8000 Zürich")

    # Table header
    y = height - 220
    c.setFont("Helvetica-Bold", 9)
    c.drawString(40, y, "Datum")
    c.drawString(100, y, "Buchungstext")
    c.drawString(width - 120, y, "Betrag CHF")

    # Line under header
    c.line(40, y - 5, width - 40, y - 5)

    # Transactions
    y -= 25
    c.setFont("Helvetica", 9)

    # Realistic Swiss transactions
    transactions = [
        # Date, Description, Amount (negative = expense, positive = income)
        ("31.01.2026", "Lohnzahlung Januar 2026", -7500.00),
        ("30.01.2026", "Miete Wohnung Zürich", 1850.00),
        ("29.01.2026", "CSS Krankenkasse Prämie", 456.90),
        ("28.01.2026", "COOP Zürich, Kaufvertrag", 89.45),
        ("28.01.2026", "Migros Oerlikon, Einkauf", 67.80),
        ("27.01.2026", "SBB Monatsabo Zone 110", 89.00),
        ("26.01.2026", "Swisscom AG Rechnung", 79.00),
        ("25.01.2026", "Restaurant Kronenhalle", 125.50),
        ("24.01.2026", "Denner Zürich HB", 34.20),
        ("23.01.2026", "VBZ Tram/Bus Ticket", 12.40),
        ("22.01.2026", "Manor Zürich, Kleidung", 187.90),
        ("21.01.2026", "Spotify Premium", 12.95),
        ("20.01.2026", "Netflix Abonnement", 17.90),
        ("19.01.2026", "COOP Zürich Bahnhofstrasse", 56.30),
        ("18.01.2026", "Migros Basel, Wocheneinkauf", 143.75),
        ("17.01.2026", "Starbucks Zürich HB", 8.50),
        ("16.01.2026", "McDonald's Zürich", 15.40),
        ("15.01.2026", "Helsana Krankenkasse Zusatz", 123.50),
        ("14.01.2026", "EWZ Stromrechnung", 145.00),
        ("13.01.2026", "Digitec Galaxus AG", 234.90),
        ("12.01.2026", "Amazon EU S.à r.l.", 67.45),
        ("11.01.2026", "COOP Zürich Seefeld", 45.20),
        ("10.01.2026", "Migros Zürich City", 78.90),
        ("09.01.2026", "SBB Billett Zürich-Bern", 52.00),
        ("08.01.2026", "Mobility Carsharing", 89.00),
        ("07.01.2026", "Parkhaus Zürich HB", 24.00),
        ("06.01.2026", "Zalando SE", 145.80),
        ("05.01.2026", "IKEA Zürich", 267.50),
        ("04.01.2026", "Coop Bau+Hobby", 89.90),
        ("03.01.2026", "Apotheke am Central", 34.50),
        ("02.01.2026", "Fitness First Zürich", 99.00),
        ("01.01.2026", "Jahresgebühr Konto", 60.00),
    ]

    for date, description, amount in transactions:
        # Check if y position is too low, create new page
        if y < 100:
            c.showPage()
            y = height - 60
            c.setFont("Helvetica", 9)

        c.drawString(40, y, date)
        c.drawString(100, y, description[:45])  # Truncate long descriptions

        # Format amount with Swiss conventions
        if amount < 0:
            # Negative (income/credit) - shown as positive on statement
            amount_str = f"{abs(amount):,.2f}".replace(",", "'")
        else:
            # Positive (expense/debit)
            amount_str = f"{amount:,.2f}".replace(",", "'")

        c.drawRightString(width - 40, y, amount_str)

        y -= 15

    # Footer with final balance
    c.line(40, y - 10, width - 40, y - 10)
    y -= 25

    c.setFont("Helvetica-Bold", 10)
    c.drawString(40, y, "Saldo / Balance:")

    # Calculate balance
    total_income = sum(abs(amt) for date, desc, amt in transactions if amt < 0)
    total_expenses = sum(amt for date, desc, amt in transactions if amt > 0)
    final_balance = total_income - total_expenses

    balance_str = f"CHF {final_balance:,.2f}".replace(",", "'")
    c.drawRightString(width - 40, y, balance_str)

    # Disclaimer
    y -= 40
    c.setFont("Helvetica", 7)
    c.drawString(40, y, "Zürcher Kantonalbank - Alle Angaben ohne Gewähr")
    c.drawString(40, y - 10, "Bitte prüfen Sie die Angaben und melden Sie Unstimmigkeiten innert 30 Tagen.")

    c.save()

    # Print summary
    print(f"✅ Created: {filename}")
    print(f"\nStatement Summary:")
    print(f"  Period: January 2026")
    print(f"  Transactions: {len(transactions)}")
    print(f"  Total Income: CHF {total_income:,.2f}".replace(",", "'"))
    print(f"  Total Expenses: CHF {total_expenses:,.2f}".replace(",", "'"))
    print(f"  Final Balance: CHF {final_balance:,.2f}".replace(",", "'"))
    print(f"\nUse this PDF to test the ZüriBudget app!")


if __name__ == "__main__":
    import sys

    try:
        from reportlab.lib.pagesizes import A4
    except ImportError:
        print("❌ Error: reportlab not installed")
        print("\nInstall it with:")
        print("  pip3 install reportlab")
        sys.exit(1)

    create_zkb_statement()
