<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="mycoreobject">
    <mycoreobject>
      <metadata>
        <def.modsContainer class="MCRMetaXML" heritable="false" notinherit="true">
          <modsContainer inherited="0">
            <mods:mods xmlns:mods="http://www.loc.gov/mods/v3">
              <mods:relatedItem type="series" xlink:href="{@ID}" xlink:type="simple">
                <xsl:copy-of select="metadata/def.modsContainer/modsContainer/mods:mods/*" />
              </mods:relatedItem>
            </mods:mods>
          </modsContainer>
        </def.modsContainer>
      </metadata>    
    </mycoreobject>
  </xsl:template>

</xsl:stylesheet>
