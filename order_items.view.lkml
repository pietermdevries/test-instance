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
        ELSE 'Gutter Level' END ;;
  }

  measure: count {
    type: count
    drill_fields: [id, orders.id, inventory_items.id]
  }
  measure: sum {
    type: sum
    drill_fields: [id,orders.id,inventory_item.id]
  }
  measure: avg {
    type: average
    drill_fields: [id,orders.id,inventory_item.id]
  }
  measure: median {
    type: median
    drill_fields: [id,orders.id,inventory_item.id]
  }
  measure: min {
    type: min
    drill_fields: [id,orders.id,inventory_item.id]
  }
  measure: max {
    type: max
    drill_fields: [id,orders.id,inventory_item.id]
  }

}
