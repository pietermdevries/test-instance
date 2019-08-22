view: order_items {
  sql_table_name: demo_db.order_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: is_cheap {
    type:  yesno
    sql: ${sale_price}<3;;
  }

  dimension: price_bracket {
    sql: CASE WHEN ${sale_price} > 100 THEN 'Top Shelf'
        WHEN ${sale_price} > 75 THEN 'Good Stuff!'
        WHEN ${sale_price} > 25 THEN 'Ok Man'
        WHEN ${sale_price} > 10 THEN 'Basic B'
        ELSE 'Gutter Level' NULL END ;;
  }

  measure: count {
    type: count
    drill_fields: [id, orders.id, inventory_items.id]
  }
}


view: user_order_facts {
  derived_table: {
    sql: SELECT
        user_id
        , COUNT(DISTINCT order_id) AS lifetime_orders
        , SUM(sale_price) AS lifetime_revenue
        , MIN(NULLIF(created_at,0)) AS first_order
        , MAX(NULLIF(created_at,0)) AS latest_order
        , COUNT(DISTINCT DATE_TRUNC('month', NULLIF(created_at,0))) AS number_of_distinct_months_with_orders
      FROM order_items
      GROUP BY user_id
       ;;
  }

  dimension: user_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: first_order {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: latest_order {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.latest_order ;;
  }

  dimension: days_as_customer {
    description: "Days between first and latest order"
    type: number
    sql: DATEDIFF('day', ${TABLE}.first_order, ${TABLE}.latest_order)+1 ;;
  }

  dimension: days_as_customer_tiered {
    type: tier
    tiers: [0, 1, 7, 14, 21, 28, 30, 60, 90, 120]
    sql: ${days_as_customer} ;;
    style: integer
  }

  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: repeat_customer {
    description: "Lifetime Count of Orders > 1"
    type: yesno
    sql: ${lifetime_orders} > 1 ;;
  }

  dimension: lifetime_orders_tier {
    type: tier
    tiers: [0, 1, 2, 3, 5, 10]
    sql: ${lifetime_orders} ;;
    style: integer
  }

  measure: average_lifetime_orders {
    type: average
    value_format_name: decimal_2
    sql: ${lifetime_orders} ;;
  }

  dimension: distinct_months_with_orders {
    type: number
    sql: ${TABLE}.number_of_distinct_months_with_orders ;;
  }

  dimension: lifetime_revenue {
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension: lifetime_revenue_tier {
    type: tier
    tiers: [0, 25, 50, 100, 200, 500, 1000]
    sql: ${lifetime_revenue} ;;
    style: integer
  }

  measure: average_lifetime_revenue {
    type: average
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }
}
