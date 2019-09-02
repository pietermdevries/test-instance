view: orders {
  sql_table_name: demo_db.orders ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      day_of_month,
      day_of_week,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: date_formatted {
    group_label: "Created"  label: "Date"
    sql: ${created_date} ;;
    html: {{ rendered_value | date: "%b %d, %y" }};;
  }

  dimension: week_formatted {
    group_label: "Created" label: "Week"
    sql: ${created_date} ;;
    html: {{rendered_value | date: "Week %U (%b %d)"}};;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [id, users.first_name, users.id, users.last_name, order_items.count]
  }
}
