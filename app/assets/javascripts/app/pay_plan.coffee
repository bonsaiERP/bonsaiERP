pay_plan_template = '
<tr id="${id}">
  <td>${_b.dateFormat(payment_date)}</td>
  <td>${_b.dateFormat(alert_date)}</td>
  <td>${_b.ntc(amount)}</td>
  <td>${_b.ntc(interests_penalties)}</td>
  <td>${description}</td>
  <td>${state}</td>
  <td class="c"><span class="${email}">&nbsp;</span></td>
  <td>
    <a title="Editar Plan de #{pay_type}" data-trigger="pay_plan" class="ajax edit" href="/pay_plans/${id}/edit?pay_type=cobro">editar</a>
    <a title="Borrar plan de #{pay_type}" class="ajax destroy" href="/pay_plans/${id}">borrar</a>
  </td>
</tr>'

