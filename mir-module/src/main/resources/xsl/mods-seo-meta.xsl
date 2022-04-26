<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="xsl mcrxml mods xlink xalan">

    <xsl:include href="mods-utils.xsl"/>

    <xsl:param name="CurrentLang" />

    <xsl:template match="mods:mods" mode="seo-meta">
        <xsl:apply-templates select="mods:abstract|mods:abstract/@xlink:href" mode="seo"/>
    </xsl:template>

    <xsl:template match="mods:abstract[not(@altFormat)] | mods:tableOfContents[not(@altFormat)]" mode="seo">
        <xsl:if test="@xml:lang = $CurrentLang" >
            <meta>
                <xsl:attribute name="name">description</xsl:attribute>
                <xsl:attribute name="content">
                    <xsl:choose>
                        <!-- SEO descriptions are limited to about 155 characters for desktop search and 120 characters
                             for mobile search. -->
                        <xsl:when test="string-length(.)>140">
                            <xsl:value-of select="mcrxml:shortenText(.,140)" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="." />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </meta>
        </xsl:if>
    </xsl:template>

    <!-- suppress all else:-->
    <xsl:template match="*" mode="seo"/>

</xsl:stylesheet>
