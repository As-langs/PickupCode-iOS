import uuid, plistlib, os, subprocess

proj_dir = '/Users/zouh/.gemini/antigravity/scratch/PickupCode-iOS'
shortcuts_dir = os.path.join(proj_dir, 'Shortcuts')
release_dir = os.path.join(proj_dir, 'release_assets')
downloads_dir = '/Users/zouh/Downloads'
os.makedirs(shortcuts_dir, exist_ok=True)
os.makedirs(release_dir, exist_ok=True)

# ----------------- Shortcut 1: 取件身份码 (4 items) -----------------
s1_items = [
    ('菜鸟身份码', 'cainiao://desktop/station_code'),
    ('淘宝身份码', 'taobao://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fmarket.m.taobao.com%2Fapp%2Fcn-yz%2Fmulti-activity%2FauthCode.html'),
    ('京东身份码', 'openapp.jdmobile://virtual?params=%7B%22category%22%3A%22jump%22%2C%22des%22%3A%22orderlist%22%7D'),
    ('拼多多身份码', 'pinduoduo://com.xunmeng.pinduoduo/mdkd/package?tab=ID_CODE&entry_source=11&refer_page_name=login&refer_page_sn=10169')
]

menu_uuid_1 = str(uuid.uuid4()).upper()
actions_1 = [
    {
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_uuid_1,
            'WFControlFlowMode': 0,
            'WFMenuItems': [title for title, _ in s1_items],
            'WFMenuPrompt': '请选择取件身份码 (4大平台)'
        }
    }
]

for title, url in s1_items:
    actions_1.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_uuid_1,
            'WFControlFlowMode': 1,
            'WFMenuItemTitle': title
        }
    })
    actions_1.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.url',
        'WFWorkflowActionParameters': {
            'WFURLActionURL': url
        }
    })
    actions_1.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.openurl',
        'WFWorkflowActionParameters': {
            'WFInput': url
        }
    })

actions_1.append({
    'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
    'WFWorkflowActionParameters': {
        'GroupingIdentifier': menu_uuid_1,
        'WFControlFlowMode': 2
    }
})

s1_dict = {
    'WFWorkflowActions': actions_1,
    'WFWorkflowClientVersion': '3300.0.4',
    'WFWorkflowClientRelease': '18.1',
    'WFWorkflowMinimumClientVersion': 900,
    'WFWorkflowIcon': {
        'WFWorkflowIconGlyphNumber': 59712,
        'WFWorkflowIconStartColor': 4282601983
    },
    'WFWorkflowTypes': ['NCWidget', 'ActionExtension']
}

# ----------------- Shortcut 2: 快递待取 (9 items) -----------------
s2_items = [
    ('淘宝待收货', 'taobao://m.taobao.com/tbopen/index.html?action=ali.open.nav&h5Url=https%3A%2F%2Fh5.m.taobao.com%2Fawp%2Fmtb%2Folist.htm%3FtabCode%3DwaitConfirm'),
    ('淘宝菜鸟待取', 'taobao://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fpages-fast.m.taobao.com%2Fwow%2Fz%2Funiapp%2F1100333%2Flast-mile-fe%2Fm-end-school-tab%2Fhome'),
    ('京东待取', 'openapp.jdmobile://virtual?params=%7B%22category%22%3A%22jump%22%2C%22des%22%3A%22orderlist%22%7D'),
    ('拼多多取快递', 'pinduoduo://com.xunmeng.pinduoduo/mdkd/package'),
    ('拼多多待收货', 'pinduoduo://com.xunmeng.pinduoduo/orders.html?type=3'),
    ('抖音待取', 'snssdk1128://ecom_order_list'),
    ('快手待取', 'kwai://webview?url=https%3A%2F%2Fapp.kwaixiaodian.com%2Fpage%2Fkwaishop-trade-order-list-app%3FlayoutType%3D4%26hyId%3DkwaishopOrder'),
    ('得物待取', 'dewuapp://m.dewu.com/router/order/buyer/orderList?tabId=0'),
    ('小红书待取', 'xhsdiscover://rn/lancer-order/order/list')
]

menu_uuid_2 = str(uuid.uuid4()).upper()
actions_2 = [
    {
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_uuid_2,
            'WFControlFlowMode': 0,
            'WFMenuItems': [title for title, _ in s2_items],
            'WFMenuPrompt': '请选择查件入口 (9大平台入口)'
        }
    }
]

for title, url in s2_items:
    actions_2.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_uuid_2,
            'WFControlFlowMode': 1,
            'WFMenuItemTitle': title
        }
    })
    actions_2.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.url',
        'WFWorkflowActionParameters': {
            'WFURLActionURL': url
        }
    })
    actions_2.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.openurl',
        'WFWorkflowActionParameters': {
            'WFInput': url
        }
    })

actions_2.append({
    'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
    'WFWorkflowActionParameters': {
        'GroupingIdentifier': menu_uuid_2,
        'WFControlFlowMode': 2
    }
})

s2_dict = {
    'WFWorkflowActions': actions_2,
    'WFWorkflowClientVersion': '3300.0.4',
    'WFWorkflowClientRelease': '18.1',
    'WFWorkflowMinimumClientVersion': 900,
    'WFWorkflowIcon': {
        'WFWorkflowIconGlyphNumber': 59712,
        'WFWorkflowIconStartColor': 4282601983
    },
    'WFWorkflowTypes': ['NCWidget', 'ActionExtension']
}

# ----------------- Shortcut 3: 取件快码 二合一 (13 items total) -----------------
menu_outer_uuid = str(uuid.uuid4()).upper()
menu_inner1_uuid = str(uuid.uuid4()).upper()
menu_inner2_uuid = str(uuid.uuid4()).upper()

combo_actions = [
    {
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_outer_uuid,
            'WFControlFlowMode': 0,
            'WFMenuItems': ['🪪 驿站身份码 (菜鸟/淘宝/京东/多多)', '📦 查询快递待取 (9大电商与快递入口)'],
            'WFMenuPrompt': '取件快码 v2.0 - 请选择模式'
        }
    },
    # Outer Case 1: 身份码
    {
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_outer_uuid,
            'WFControlFlowMode': 1,
            'WFMenuItemTitle': '🪪 驿站身份码 (菜鸟/淘宝/京东/多多)'
        }
    },
    {
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_inner1_uuid,
            'WFControlFlowMode': 0,
            'WFMenuItems': [title for title, _ in s1_items],
            'WFMenuPrompt': '请选择取件身份码'
        }
    }
]

for title, url in s1_items:
    combo_actions.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_inner1_uuid,
            'WFControlFlowMode': 1,
            'WFMenuItemTitle': title
        }
    })
    combo_actions.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.url',
        'WFWorkflowActionParameters': {
            'WFURLActionURL': url
        }
    })
    combo_actions.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.openurl',
        'WFWorkflowActionParameters': {
            'WFInput': url
        }
    })

combo_actions.append({
    'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
    'WFWorkflowActionParameters': {
        'GroupingIdentifier': menu_inner1_uuid,
        'WFControlFlowMode': 2
    }
})

# Outer Case 2: 快递待取
combo_actions.append({
    'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
    'WFWorkflowActionParameters': {
        'GroupingIdentifier': menu_outer_uuid,
        'WFControlFlowMode': 1,
        'WFMenuItemTitle': '📦 查询快递待取 (9大电商与快递入口)'
    }
})
combo_actions.append({
    'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
    'WFWorkflowActionParameters': {
        'GroupingIdentifier': menu_inner2_uuid,
        'WFControlFlowMode': 0,
        'WFMenuItems': [title for title, _ in s2_items],
        'WFMenuPrompt': '请选择查件入口 (9大平台入口)'
    }
})

for title, url in s2_items:
    combo_actions.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
        'WFWorkflowActionParameters': {
            'GroupingIdentifier': menu_inner2_uuid,
            'WFControlFlowMode': 1,
            'WFMenuItemTitle': title
        }
    })
    combo_actions.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.url',
        'WFWorkflowActionParameters': {
            'WFURLActionURL': url
        }
    })
    combo_actions.append({
        'WFWorkflowActionIdentifier': 'is.workflow.actions.openurl',
        'WFWorkflowActionParameters': {
            'WFInput': url
        }
    })

combo_actions.append({
    'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
    'WFWorkflowActionParameters': {
        'GroupingIdentifier': menu_inner2_uuid,
        'WFControlFlowMode': 2
    }
})

# Outer Menu End
combo_actions.append({
    'WFWorkflowActionIdentifier': 'is.workflow.actions.choosefrommenu',
    'WFWorkflowActionParameters': {
        'GroupingIdentifier': menu_outer_uuid,
        'WFControlFlowMode': 2
    }
})

combo_dict = {
    'WFWorkflowActions': combo_actions,
    'WFWorkflowClientVersion': '3300.0.4',
    'WFWorkflowClientRelease': '18.1',
    'WFWorkflowMinimumClientVersion': 900,
    'WFWorkflowIcon': {
        'WFWorkflowIconGlyphNumber': 59712,
        'WFWorkflowIconStartColor': 4282601983
    },
    'WFWorkflowTypes': ['NCWidget', 'ActionExtension']
}

targets = [
    ('取件身份码_raw.shortcut', '取件身份码.shortcut', 'PickupCode_ID_取件身份码.shortcut', s1_dict),
    ('快递待取_raw.shortcut', '快递待取.shortcut', 'PickupCode_Packages_快递待取.shortcut', s2_dict),
    ('取件快码_二合一_raw.shortcut', '取件快码_二合一.shortcut', 'PickupCode_AllInOne_取件快码.shortcut', combo_dict)
]

for raw_name, signed_name, release_name, d in targets:
    raw_path = os.path.join(shortcuts_dir, raw_name)
    signed_path = os.path.join(shortcuts_dir, signed_name)
    release_path = os.path.join(release_dir, release_name)
    
    with open(raw_path, 'wb') as f:
        plistlib.dump(d, f, fmt=plistlib.FMT_BINARY)
    
    print(f'Signing {signed_name}...')
    subprocess.run(['shortcuts', 'sign', '--mode', 'anyone', '--input', raw_path, '--output', signed_path], check=True)
    subprocess.run(['cp', signed_path, release_path], check=True)
    os.remove(raw_path)

print('All 3 shortcuts regenerated and signed for v2.0.0!')
