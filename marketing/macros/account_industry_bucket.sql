{% macro account_industry_bucket(industry_column) %}
CASE
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        'tele.*|cable & satellite'
    ) THEN 'Telco'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        '(hospitals|health|medical).*|healthcare & pharmaceuticals'
    ) THEN 'Healthcare'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        'media|.*(multimedia|publishing|movie|music|entertainment - media/music/broadcast|gaming|broadcast|print & digital media).*'
    ) THEN 'Media & Entertainment'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        'retail|.*(consumer|retail|consumer products|retail & e-commerce|leisure, travel & hospitality|hospitality).*'
    ) THEN 'Retail'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        '(software|consumer services|information|software development|\bit\b).*'
    ) THEN 'IT Software'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        '(government|public sector|defence & security|aerospace|irs|colleges|universities|university|education|federal|government).*'
    ) THEN 'Public Sector'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        '(brokerage|accountancy & tax|banking & finance|insur|banking|finance|account|financial).*'
    ) THEN 'Finance'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        'automotive|(automotive parts|automotive service & collision repair).*'
    ) THEN 'Automotive'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        '(industrial|manufacturing).*'
    ) THEN 'Industrial Manufacturing'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        '(transport|logistics).*'
    ) THEN 'Transport'
    WHEN REGEXP_LIKE(
        LOWER({{ industry_column }}),
        '(energy|gas|oil|mining).*'
    ) THEN 'Energy'
    ELSE 'Other'
END
{% endmacro %}