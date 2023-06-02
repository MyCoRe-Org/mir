<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:exslt="http://exslt.org/common"
                xmlns:mods="http://www.loc.gov/mods/v3"
                exclude-result-prefixes="exslt i18n mods"
>


    <xsl:import
            href="xslImport:modsmeta:metadata/mir-thumbnail.xsl"/>
    <xsl:template match="/">
        <xsl:if test="mycoreobject/structure/derobjects/derobject[classification/@categid='thumbnail']">
            <xsl:variable name="defaultAlt"
                          select="concat(mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title,' ',i18n:translate('mir.metaData.panel.heading.mir-thumbnail'))"/>
            <xsl:variable name="identifier" select="mycoreobject/@ID"/>
            <xsl:variable name="pictureURL"
                          select="concat($WebApplicationBaseURL, 'api/iiif/image/v2/thumbnail/', $identifier,'/full/!400,400/0/default.jpg')"/>
            <div id="mir-thumbnail">
                <img src="{$pictureURL}" alt="{$defaultAlt}" class="img-fluid"/>
            </div>
        </xsl:if>
        <xsl:apply-imports/>
    </xsl:template>
</xsl:stylesheet>