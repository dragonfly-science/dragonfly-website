#! /usr/bin/python
"""
Updates the tags in the front matter of the YAML file, by reading them in fromm tags.csv.
To generate the tags.csv file run './tags_extract.sh' in the publications directory
"""
count = 0
alltags = set()
for line in open('tags.csv').readlines():
    tags = [x.strip() for x in line.split(',')]
    alltags.update([x.strip() for x in tags[1:]])
    rows = []
    header = False
    tagged = False
    for row in open(tags[0]).readlines():
        if not header and row.startswith('---'):
            header = True
        elif header and row.startswith('---'):
            header = False
            if not tagged:
                row = 'tags: ' + ', '.join(tags[1:]) + '\n---'
                tagged = True
                count += 1
        elif header and not tagged and row.startswith('tags:'):
            oldrow = row
            row = 'tags: ' + ', '.join(tags[1:])
            tagged = True
            count += (oldrow.strip() != row.strip())
        rows.append(row)
    o = open(tags[0], 'w')
    for row in rows:
        o.write(row.strip() + '\n')
    o.close()
print 'Updated %s files' % count
print ', '.join(alltags)
