module ReportHelper
#   def chart_data(x_axis_data, y_axis_data, legend_names)
#     color = chart_colors
#     data  = { labels: x_axis_data, datasets: [] }
#
#     y_axis_data.each_with_index do |level, i|
#       data[:datasets] << { label: legend_names[i],         fill: false, borderColor: color[i],
#                            pointBorderColor: color[i], data: level, backgroundColor: color[i]}
#     end
#
#     data
#   end
#
#   def chart_colors
#     [
#         '#B576AD', # 1. Violete
#         '#FD505A', # 2. Red
#         '#E2CB5A', # 3. Gold
#         '#50BB70', # 4. Light Green
#         '#47A7D4', # 5. Teal
#         '#FB79AD', # 6. Pink
#         '#7B241C', # 7. Brown
#         '#FF9E51', # 8. Orange
#         '#0B5345', # 9. Dark Green
#         '#154360', # 10. Navy Blue
#         # Colors repeat
#         '#B576AD','#FD505A','#E2CB5A','#50BB70','#47A7D4','#FB79AD','#7B241C','#FF9E51','#0B5345','#154360',
#         '#B576AD','#FD505A','#E2CB5A','#50BB70','#47A7D4','#FB79AD','#7B241C','#FF9E51','#0B5345','#154360',
#         '#B576AD','#FD505A','#E2CB5A','#50BB70','#47A7D4','#FB79AD','#7B241C','#FF9E51','#0B5345','#154360',
#     ]
#   end
end