import sys

path = "/home/ubuntu/openturath-backend/prod/main.py"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

old_block = '''    all_access_plans = [
        {"plan": "tholib_1m", "months": 1, "amount": 499000, "revision": "vps-prod-20261111"},
        {"plan": "tholib_6m", "months": 6, "amount": 2499000, "revision": "vps-prod-20261111"},
        {"plan": "bahits_1y", "months": 12, "amount": 3999000, "revision": "vps-prod-20261111"}
    ]
    all_access_agents = ["all_ai", "all_access", "maktabah_all"]'''

new_block = '''    all_access_plans = [
        {"plan": "tholib_1m", "months": 1, "amount": 499000, "revision": "vps-prod-20261111"},
        {"plan": "tholib_6m", "months": 6, "amount": 2499000, "revision": "vps-prod-20261111"},
        {"plan": "bahits_1y", "months": 12, "amount": 3999000, "revision": "vps-prod-20261111"}
    ]
    all_access_agents = ["all_ai", "all_access", "maktabah_all"]

    all_specialists_bundle_plans = by_product.get("all_specialists", [
        {"plan": "tholib_1m", "months": 1, "amount": 300000, "revision": "vps-prod-20261111"},
        {"plan": "tholib_6m", "months": 6, "amount": 1500000, "revision": "vps-prod-20261111"},
        {"plan": "bahits_1y", "months": 12, "amount": 2500000, "revision": "vps-prod-20261111"}
    ])
    all_specialists_bundle_agents = ["all_specialists", "all_disciplines", "semua_ai_non_tahawwulat"]'''

if old_block not in content:
    print("ERROR: old_block not found!")
    sys.exit(1)

content = content.replace(old_block, new_block, 1)

old_loop = '''    for agent_id in all_access_agents:
        if agent_id not in seen_agents:
            seen_agents.add(agent_id)
            offers.append({
                "agentId": agent_id,
                "plans": all_access_plans
            })'''

new_loop = '''    for agent_id in all_access_agents:
        if agent_id not in seen_agents:
            seen_agents.add(agent_id)
            offers.append({
                "agentId": agent_id,
                "plans": all_access_plans
            })

    for agent_id in all_specialists_bundle_agents:
        if agent_id not in seen_agents:
            seen_agents.add(agent_id)
            offers.append({
                "agentId": agent_id,
                "plans": all_specialists_bundle_plans
            })'''

if old_loop not in content:
    print("ERROR: old_loop not found!")
    sys.exit(1)

content = content.replace(old_loop, new_loop, 1)

old_scope = '    scope = "fiqh_tahawwulat" if "tahawwulat" in agent_id.lower() or "06." in agent_id.lower() else "fiqh_syafii"'
new_scope = '''    agent_id_lower = agent_id.lower()
    if "tahawwulat" in agent_id_lower or "06." in agent_id_lower:
        scope = "fiqh_tahawwulat"
    elif "all_specialist" in agent_id_lower or "all_discipline" in agent_id_lower or "non_tahawwulat" in agent_id_lower or "tanpa_tahawwulat" in agent_id_lower:
        scope = "all_specialists"
    elif "all_ai" in agent_id_lower or "all_access" in agent_id_lower:
        scope = "all_access"
    else:
        scope = "fiqh_syafii"'''

if old_scope not in content:
    print("ERROR: old_scope not found!")
    sys.exit(1)

content = content.replace(old_scope, new_scope, 1)

old_amount_check = 'if custom_amount and isinstance(custom_amount, (int, float)) and custom_amount >= 10000:'
new_amount_check = 'if custom_amount and isinstance(custom_amount, (int, float)) and custom_amount >= 1000:'

if old_amount_check not in content:
    print("ERROR: old_amount_check not found!")
    sys.exit(1)

content = content.replace(old_amount_check, new_amount_check, 1)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("SUCCESS: main.py updated cleanly!")
