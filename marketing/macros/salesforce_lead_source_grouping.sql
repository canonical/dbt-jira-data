{% macro salesforce_lead_source_grouping(source_column) %} 
CASE
    WHEN {{ source_column }} IN (
        'Web form',
        'Blog',
        'Webinar',
        'Contact form',
        'Snapcraft.io',
        'Livechat',
        'Online Purchase - Canonical Store',
        'Inbound phone call',
        'Linkedin Form',
        'Subscription Centre',
        'Insights',
        'WeChat',
        'Canonical Shopify Shop'
    )
    or {{ source_column }} like 'Azure%%' THEN CASE
        WHEN {{ source_column }} IN (
            'Web form',
            'Blog',
            'Webinar',
            'Contact form',
            'Snapcraft.io'
        ) THEN {{ source_column }}
        ELSE 'Other Inbound'
    END
    WHEN {{ source_column }} IN (
        'ZoomInfo',
        'Event / tradeshow',
        'Lusha',
        'RocketReach Sync',
        'Echobot',
        'Purchased List',
        'Salesforce leads',
        'Linkedin: Sales Navigator',
        'ISV .NET Campaign',
        'TechTarget',
        'Prospect Growth',
        'LinkedIn',
        'CY22_Intensify_leads_upload',
        'Azure Co-Sell',
        'Customer Growth',
        'Partner-supplied',
        'NASA Goddard Cybersecurity Day',
        'Rep Generated',
        'Trade Show',
        'SDR Generated',
        'MailChimp data',
        'Event / trade show',
        'Salesforce.com',
        'TechTarget QSO',
        'Strata & Hadoop World event',
        'LinkedIn: Unpaid/Basic'
    ) THEN CASE
        WHEN {{ source_column }} IN (
            'ZoomInfo',
            'Event / tradeshow',
            'Lusha',
            'RocketReach Sync',
            'Echobot'
        ) THEN {{ source_column }}
        ELSE 'Other Outbound'
    END
    ELSE 'Other'
END {% endmacro %}