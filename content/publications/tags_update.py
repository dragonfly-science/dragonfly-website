#! /usr/bin/python
"""
Updates the tags in the front matter of the YAML file, by reading them in fromm tags.csv.
To generate the tags.csv file run './tags_extract.sh' in the publications directory
"""
count = 0
alltags = set()
for line in open('tags.csv').readlines():
    tags = [x.strip() for x in line.split(',') if len(x.strip()) > 0]
    alltags.update(tags[1:])
    rows = []
    header = False
    tagged = False
    try:
        mdfile = open(tags[0]).readlines()
        for rowcount, row in enumerate(mdfile):
            if rowcount == 0 and not row.startswith('---'):
                print 'Incorrectly formatted file: %s' % tags[0]
            if not header and row.startswith('---'):
                header = True
            elif header and row.startswith('---'):
                header = False
                if not tagged:
                    row = 'tags: ' + ', '.join(tags[1:]) + '\n---'
                    tagged = True
                    count += 1
            elif header and not tagged and row.startswith('tags:'):
                oldrow = str(row)
                row = 'tags: ' + ', '.join(tags[1:])
                tagged = True
                count += (oldrow.strip() != row.strip())
            rows.append(row)
        o = open(tags[0], 'w')
        for row in rows:
            o.write(row.strip() + '\n')
        o.close()
    except IOError:
        print "Couldn't find %s" % tags[0]
print 'Updated %s files' % count
print ', '.join(alltags)
