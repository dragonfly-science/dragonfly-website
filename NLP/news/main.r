library(data.table)

source('../rbol.r')
source('project-config.r')
source('project-functions.r')

options('mc.cores' = 6)

make.project(project.defaults, project.functions = project.functions, run.function = run)

run()

