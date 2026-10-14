<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirmapper="http://www.mycore.de/xslt/mirmapper"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirmapper:classid" as="xs:string">
    <xsl:param name="categ-ref" as="xs:string?" />
    <xsl:sequence select="substring-before(normalize-space($categ-ref), ':')" />
  </xsl:function>

  <xsl:function name="mirmapper:categid" as="xs:string">
    <xsl:param name="categ-ref" as="xs:string?" />
    <xsl:sequence select="substring-after(normalize-space($categ-ref), ':')" />
  </xsl:function>

  <xsl:function name="mirmapper:class-uri" as="xs:string?">
    <xsl:param name="classid" as="xs:string?" />
    <xsl:variable name="normalized" select="normalize-space($classid)" />
    <xsl:choose>
      <xsl:when test="$normalized = ''">
        <xsl:sequence select="()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="document(concat('classification:metadata:0:children:', $normalized))/mycoreclass/label[@xml:lang='x-uri']/@text/string()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mirmapper:getSDNBfromOldSDNB" as="xs:string">
    <xsl:param name="sdnb" as="xs:string" />
    <xsl:choose>
      <xsl:when test="$sdnb = ('01', '02', '03', '06')">000</xsl:when>
      <xsl:when test="$sdnb = '07'">K</xsl:when>
      <xsl:when test="$sdnb = '08'">741.5</xsl:when>
      <xsl:when test="$sdnb = '09'">130</xsl:when>
      <xsl:when test="$sdnb = '10'">100</xsl:when>
      <xsl:when test="$sdnb = '11'">150</xsl:when>
      <xsl:when test="$sdnb = ('12', '13')">200</xsl:when>
      <xsl:when test="$sdnb = '15'">310</xsl:when>
      <xsl:when test="$sdnb = '16'">320</xsl:when>
      <xsl:when test="$sdnb = ('17', '18', '19')">300</xsl:when>
      <xsl:when test="$sdnb = '20'">350</xsl:when>
      <xsl:when test="$sdnb = '21'">355</xsl:when>
      <xsl:when test="$sdnb = '22'">370</xsl:when>
      <xsl:when test="$sdnb = '23'">S</xsl:when>
      <xsl:when test="$sdnb = '25'">390</xsl:when>
      <xsl:when test="$sdnb = '26'">500</xsl:when>
      <xsl:when test="$sdnb = '27'">510</xsl:when>
      <xsl:when test="$sdnb = '28'">004</xsl:when>
      <xsl:when test="$sdnb = '29'">500</xsl:when>
      <xsl:when test="$sdnb = '30'">540</xsl:when>
      <xsl:when test="$sdnb = ('31', '32')">500</xsl:when>
      <xsl:when test="$sdnb = '33'">610</xsl:when>
      <xsl:when test="$sdnb = '34'">630</xsl:when>
      <xsl:when test="$sdnb = ('35', '36', '38')">600</xsl:when>
      <xsl:when test="$sdnb = '37'">621.3</xsl:when>
      <xsl:when test="$sdnb = '39'">630</xsl:when>
      <xsl:when test="$sdnb = '40'">640</xsl:when>
      <xsl:when test="$sdnb = '41'">760</xsl:when>
      <xsl:when test="$sdnb = '42'">700</xsl:when>
      <xsl:when test="$sdnb = '43'">640</xsl:when>
      <xsl:when test="$sdnb = '44'">710</xsl:when>
      <xsl:when test="$sdnb = '45'">720</xsl:when>
      <xsl:when test="$sdnb = '46'">700</xsl:when>
      <xsl:when test="$sdnb = '47'">770</xsl:when>
      <xsl:when test="$sdnb = '48'">780</xsl:when>
      <xsl:when test="$sdnb = ('49', '50')">790</xsl:when>
      <xsl:when test="$sdnb = ('51', '52', '55', '56', '59', '65')">800</xsl:when>
      <xsl:when test="$sdnb = '53'">830</xsl:when>
      <xsl:when test="$sdnb = '54'">839</xsl:when>
      <xsl:when test="$sdnb = ('57', '58')">890</xsl:when>
      <xsl:when test="$sdnb = '60'">900</xsl:when>
      <xsl:when test="$sdnb = ('61', '62')">910</xsl:when>
      <xsl:when test="$sdnb = ('63', '64')">900</xsl:when>
      <xsl:when test="$sdnb = '78'">Y</xsl:when>
      <xsl:when test="$sdnb = '79'">Z</xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$sdnb" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mirmapper:getSDNBfromDDC" as="xs:string">
    <xsl:param name="ddc-string" as="xs:string?" />
    <xsl:variable name="normalized" select="replace(normalize-space($ddc-string), '[^0-9.]', '')" />
    <xsl:variable name="ddc" select="if ($normalized != '') then xs:decimal($normalized) else ()" />
    <xsl:choose>
      <xsl:when test="empty($ddc)">
        <xsl:sequence select="''" />
      </xsl:when>
      <xsl:when test="$ddc ge 0 and $ddc lt 4">000</xsl:when>
      <xsl:when test="$ddc ge 4 and $ddc lt 7">004</xsl:when>
      <xsl:when test="($ddc ge 100 and $ddc lt 130) or ($ddc ge 140 and $ddc lt 150) or ($ddc ge 160 and $ddc lt 200)">100</xsl:when>
      <xsl:when test="$ddc ge 210 and $ddc lt 220">200</xsl:when>
      <xsl:when test="$ddc ge 230 and $ddc lt 290">230</xsl:when>
      <xsl:when test="$ddc ge 333.7 and $ddc lt 334">333.7</xsl:when>
      <xsl:when test="$ddc ge 350 and $ddc lt 355">350</xsl:when>
      <xsl:when test="$ddc ge 355 and $ddc lt 360">355</xsl:when>
      <xsl:when test="$ddc ge 410 and $ddc lt 420">400</xsl:when>
      <xsl:when test="$ddc ge 439 and $ddc lt 440">439</xsl:when>
      <xsl:when test="$ddc ge 491.7 and $ddc lt 491.9">491.8</xsl:when>
      <xsl:when test="$ddc ge 621 and $ddc lt 622 and not($ddc = (621.3, 621.46))">620</xsl:when>
      <xsl:when test="$ddc ge 623 and $ddc lt 624">620</xsl:when>
      <xsl:when test="$ddc = (625.19, 625.2)">620</xsl:when>
      <xsl:when test="$ddc ge 629 and $ddc lt 630 and not($ddc = 629.8)">620</xsl:when>
      <xsl:when test="$ddc = (621.3, 621.46, 629.8)">621.3</xsl:when>
      <xsl:when test="$ddc ge 622 and $ddc lt 623">624</xsl:when>
      <xsl:when test="$ddc ge 624 and $ddc lt 629 and not($ddc = (625.19, 625.2))">624</xsl:when>
      <xsl:when test="$ddc ge 680 and $ddc lt 690">670</xsl:when>
      <xsl:when test="$ddc = 741.5">741.5</xsl:when>
      <xsl:when test="$ddc ge 791 and $ddc lt 792">791</xsl:when>
      <xsl:when test="$ddc ge 792 and $ddc lt 793">792</xsl:when>
      <xsl:when test="$ddc ge 793 and $ddc lt 796">793</xsl:when>
      <xsl:when test="$ddc ge 796 and $ddc lt 800">796</xsl:when>
      <xsl:when test="$ddc ge 839 and $ddc lt 840">839</xsl:when>
      <xsl:when test="$ddc ge 891.7 and $ddc lt 891.9">891.8</xsl:when>
      <xsl:when test="$ddc ge 914.3 and $ddc lt 914.36">914.3</xsl:when>
      <xsl:when test="$ddc ge 943 and $ddc lt 943.6">943</xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="format-number(floor($ddc div 10) * 10, if ($ddc lt 100) then '000' else '0')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
