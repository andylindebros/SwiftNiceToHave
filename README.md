# NiceToHave Swift functions
This package provides Swift functions that you write all over and over. So instead of write the same function again, the function can be accessed from this package.



# Generate tokens from exported Material Design Figma json 

``` Swift
    cd {root of project}
    swift package plugin generate-code \
    --schema { path to your json schema } \
    --output { path to the output folder } \
  --type main | module. If you generate to the project: main, if you generate to a swift package: module
```

Schema structure
``` json
{
    "borderRadius": {
      "small": {
        "value": "4px",
        "type": "borderRadius"
      }
    },
  "spacing": {
      "spacing-00": {
        "value": "4",
        "type": "spacing"
      }
    },
  "opacity": {
    "primary": {
      "light": {
        "value": "100%"
      },
      "dark": {
        "value": "100%"
      }
    }
  },
  "colors": {
      "light": {
          "primary": "#4B662C"
      },
      "dark": {
          "primary": "#B1D18A"
      }
  },
  "shadow": {
    "primary": {
      "light": {
        "value": {
          "x": "0",
          "y": "4",
          "blur": "16",
          "spread": "0",
          "color": "rgba(0,0,0,0.24)",
          "type": "dropShadow"
        },
        "type": "boxShadow"
      },
      "dark": {
        "value": {
          "x": "0",
          "y": "4",
          "blur": "16",
          "spread": "0",
          "color": "rgba(0,0,0,0.32)",
          "type": "dropShadow"
        },
        "type": "boxShadow"
      }
    }
  },
  "font": {
      "config": {
          "fontFamilies": {
            "someFont": {
              "value": "SomeFont",
              "type": "fontFamilies"
            }
          },
          "lineHeights": {
            "0": {
              "value": "80",
              "type": "lineHeights"
            }
          },
          "fontWeights": {
            "someFont-0": {
              "value": "Regular",
              "type": "fontWeights"
            },
            "someFont-1": {
              "value": "Bold",
              "type": "fontWeights"
            }
          },
          "fontSize": {
            "0": {
              "value": "12",
              "type": "fontSizes"
            },
            "1": {
              "value": "14",
              "type": "fontSizes"
            }
          },
          "paragraphSpacing": {
            "0": {
              "value": "0",
              "type": "paragraphSpacing"
            }
          },
          "textCase": {
            "none": {
              "value": "none",
              "type": "textCase"
            }
          },
          "textDecoration": {
            "none": {
              "value": "none",
              "type": "textDecoration"
            }
          },
          "paragraphIndent": {
            "0": {
              "value": "0px",
              "type": "dimension"
            }
          }
      },
      "properties": {
          "Display": {
            "Large": {
              "Regular": {
                "value": {
                    "fontFamily": "SomeFont",
                    "fontWeight": "Regular",
                    "lineHeight": "21",
                    "fontSize": "16",
                    "letterSpacing": "0",
                    "paragraphSpacing": "0",
                    "paragraphIndent": "0",
                    "textCase": "none",
                    "textDecoration": "none"
                },
                "type": "typography"
              }
            }
          }
        }
  }
}

```
