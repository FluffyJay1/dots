#!/bin/bash
# lmao
placeholder="tagnum"
tagString="              - map:
                  conditions:
                    tag_${placeholder}_occupied:
                      map:
                        conditions:
                          tag_${placeholder}_focused: {string: {text: \"{tag_${placeholder}}\", <<: *focused}}
                          ~tag_${placeholder}_focused: {string: {text: \"{tag_${placeholder}}\", <<: *occupied}}
                    ~tag_${placeholder}_occupied:
                      map:
                        conditions:
                          tag_${placeholder}_focused: {string: {text: \"{tag_${placeholder}}\", <<: *focused}}
                          ~tag_${placeholder}_focused: {string: {text: \"{tag_${placeholder}}\", <<: *empty}}"
    
    numLines=$(($(echo "$tagString" | wc -l) * 9))
    echo "              # the next $numLines lines were generated with :r!yamconftags.sh"
for i in {0..8}; do
	echo "$tagString" | sed -r "s/${placeholder}/${i}/g"
done
