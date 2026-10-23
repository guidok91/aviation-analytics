{% macro create_source_tables() -%}

    {%- for node in graph.sources.values() -%}

        {%- set relation = source(node.source_name, node.name) -%}
        {%- set columns = [] -%}
        {%- for column in node.columns.values() -%}
            {%- do columns.append(adapter.quote(column.name) ~ ' ' ~ column.data_type) -%}
        {%- endfor -%}

        {%- do adapter.create_schema(relation) -%}
        {%- do run_query('CREATE TABLE IF NOT EXISTS ' ~ relation ~ ' (' ~ columns | join(', ') ~ ')') -%}

    {%- endfor -%}

{%- endmacro %}
