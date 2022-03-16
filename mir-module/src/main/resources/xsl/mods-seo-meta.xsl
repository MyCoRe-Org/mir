<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="xsl mods xlink xalan">

    <xsl:include href="mods-utils.xsl"/>

    <xsl:param name="CurrentLang" />

    <xsl:template match="mods:mods" mode="seo-meta">
        <xsl:apply-templates select="mods:abstract|mods:abstract/@xlink:href" mode="seo"/>
    </xsl:template>

    <xsl:template match="mods:abstract[not(@altFormat)] | mods:tableOfContents[not(@altFormat)]" mode="seo">
        <xsl:if test="@xml:lang = $CurrentLang" >
            <meta>
                <xsl:attribute name="name">Description</xsl:attribute>
                <xsl:attribute name="content">
                    <xsl:value-of select="concat(substring(.,0,141), '...')" />
                </xsl:attribute>
            </meta>
        </xsl:if>
    </xsl:template>

    <!-- suppress all else:-->
    <xsl:template match="*" mode="seo"/>

</xsl:stylesheet>
