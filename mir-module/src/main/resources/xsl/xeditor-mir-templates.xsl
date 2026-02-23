<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mir="http://www.mycore.de/mir"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n mir xalan xsl">

  <xsl:include href="copynodes.xsl" />

  <xsl:param name="MIR.Layout.inputSize" />
  <xsl:param name="MIR.Layout.inputWidth" />
  <xsl:param name="MCR.XEditor.Validation.Marker.error" />

  <xsl:variable name="grid-width" select="12" />
  <xsl:variable name="input-size">
    <xsl:choose>
      <xsl:when test="string-length($MIR.Layout.inputSize) &gt; 0">
        <xsl:value-of select="$MIR.Layout.inputSize" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>md</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="input-width">
    <xsl:choose>
      <xsl:when test="string-length($MIR.Layout.inputWidth) &gt; 0">
        <xsl:value-of select="$MIR.Layout.inputWidth" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="9" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="label-width" select="$grid-width - $input-width" />

  <xsl:template match="mir:template[contains('textInput|passwordInput|selectInput|checkboxList|radioList|textArea|static', @name)]">
    <xed:bind xpath="{@xpath}">
      <xsl:if test="string-length(@default) &gt; 0">
        <xsl:attribute name="default">
          <xsl:value-of select="@default" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="string-length(@initially) &gt; 0">
        <xsl:attribute name="initially">
          <xsl:value-of select="@initially" />
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="contains('textInput|passwordInput|selectInput|static', @name) and (@inline = 'true')">
          <xsl:apply-templates select="." mode="inline" />
        </xsl:when>
        <xsl:otherwise>
          <div>
            <xsl:attribute name="class">mir-form-group row {$xed-validation-marker}</xsl:attribute>
            <xsl:apply-templates select="." mode="formline" />
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xed:bind>
  </xsl:template>

  <xsl:template match="mir:template[@name='submitButton']">
    <xsl:variable name="target">
      <xsl:choose>
        <xsl:when test="@target">
          <xsl:value-of select="@target" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'debug'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <button type="submit" xed:target="{$target}" class="btn btn-primary btn-{$input-size} {@class}">
      <xsl:copy-of select="@order" />
      <xsl:if test="string-length(@href) &gt; 0">
        <xsl:attribute name="xed:href">
          <xsl:value-of select="@href" />
        </xsl:attribute>
      </xsl:if>
      <xed:output i18n="{@i18n}" />
    </button>
  </xsl:template>

  <xsl:template match="mir:template[@name='cancelButton']">
    <button type="submit" xed:target="cancel" class="btn btn-secondary btn-{$input-size}">
      <xed:output i18n="{@i18n}" />
    </button>
  </xsl:template>

  <!-- MODE=formline -->

  <xsl:template match="mir:template[contains('textInput|passwordInput|selectInput|checkboxList|radioList|textArea|static', @name)]" mode="formline">
    <xsl:if test="string-length(@i18n) &gt; 0">
      <xsl:apply-templates select="." mode="label" />
    </xsl:if>
    <div>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="$input-size = 'xs'">
            <xsl:value-of select="concat('col-', $input-width, ' ')" />
            <xsl:if test="string-length(@i18n) = 0">
              <xsl:value-of select="concat('offset-', $label-width, ' ')" />
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('col-', $input-size, '-', $input-width, ' ')" />
            <xsl:if test="string-length(@i18n) = 0">
              <xsl:value-of select="concat('offset-', $input-size, '-', $label-width, ' ')" />
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="'{$xed-validation-marker}'" />
      </xsl:attribute>

      <xsl:choose>
        <xsl:when test="count(action) &gt; 0">
          <div class="input-group">
            <xsl:apply-templates select="." mode="action" />
            <xsl:apply-templates select="." mode="widget" />
            <xsl:apply-templates select="." mode="validation" />
          </div>
        </xsl:when>
        <xsl:when test="@tooltip">
          <div class="input-group">
            <xsl:apply-templates select="." mode="widget" />
            <xsl:apply-templates select="." mode="inputTooltip" />
            <xsl:apply-templates select="." mode="validation" />
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="widget" />
          <xsl:apply-templates select="." mode="validation" />
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- MODE=inline -->

  <xsl:template match="mir:template[contains('textInput|passwordInput|selectInput|static', @name)]" mode="inline">
    <xsl:variable name="colsize">
      <xsl:choose>
        <xsl:when test="string-length(@colsize) &gt; 0">
          <xsl:value-of select="@colsize" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$input-size" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="colwidth">
      <xsl:choose>
        <xsl:when test="string(number(@colwidth)) != 'NaN'">
          <xsl:value-of select="@colwidth" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$input-width" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="$colsize = 'xs'">
            <xsl:value-of select="concat('col-', $colwidth, ' ')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('col-', $colsize, '-', $colwidth, ' ')" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="'{$xed-validation-marker}'" />
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="count(action) &gt; 0">
          <div class="input-group">
            <xsl:apply-templates select="." mode="action" />
            <xsl:apply-templates select="." mode="widget" />
            <xsl:apply-templates select="." mode="validation" />
          </div>
        </xsl:when>
        <xsl:when test="@tooltip">
          <div class="input-group">
            <xsl:apply-templates select="." mode="widget" />
            <xsl:apply-templates select="." mode="inputTooltip" />
            <xsl:apply-templates select="." mode="validation" />
          </div>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="widget" />
          <xsl:apply-templates select="." mode="validation" />
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- MODE=validation -->

  <xsl:template match="mir:template[contains('textInput|passwordInput|selectInput|checkboxList|radioList|textArea', @name)]" mode="validation">
    <xsl:if test="@required = 'true' or @validate = 'true'">
      <xed:if test="contains($xed-validation-marker, $MCR.XEditor.Validation.Marker.error)">
        <div class="invalid-feedback">
          <xed:output i18n="{@i18n.error}" />
        </div>
      </xed:if>
      <xed:validate display="local" required="{@required}">
        <xsl:copy-of select="@*[contains('matches|test|format|type', name())]" />
        <xed:output i18n="{@i18n.error}" />
      </xed:validate>
    </xsl:if>
  </xsl:template>

  <!-- MODE=widget -->

  <xsl:template match="mir:template[@name='textInput']" mode="widget">
    <input type="text" id="{@id}">
      <xsl:attribute name="class">
        <xsl:value-of select="concat('form-control input-', $input-size, ' ', @class, ' ', '{$xed-validation-marker}')" />
      </xsl:attribute>
      <xsl:apply-templates select="." mode="inputOptions" />
    </input>
  </xsl:template>

  <xsl:template match="mir:template[@name='passwordInput']" mode="widget">
    <input type="password" class="form-control input-{$input-size} {@class}" id="{@id}">
      <xsl:apply-templates select="." mode="inputOptions" />
    </input>
  </xsl:template>

  <xsl:template match="mir:template[@name='selectInput']" mode="widget">
    <select id="{@id}">
      <xsl:attribute name="class">
        <xsl:value-of select="concat('form-control form-select input-', $input-size, ' ', @class, ' ', '{$xed-validation-marker}')" />
      </xsl:attribute>
      <xsl:apply-templates select="." mode="inputOptions" />
      <xsl:if test="not(@inlcudeOnly = 'true')">
        <option value="">
          <xed:output i18n="mir.select" />
        </option>
      </xsl:if>
      <xed:include uri="{@uri}" />
    </select>
  </xsl:template>

  <xsl:template match="mir:template[@name='textArea']" mode="widget">
    <textarea id="{@id}">
      <xsl:attribute name="class">
        <xsl:value-of select="concat('form-control input-', $input-size, ' ', @class, ' ', '{$xed-validation-marker}')" />
      </xsl:attribute>
      <xsl:attribute name="rows">
        <xsl:choose>
          <xsl:when test="@rows">
            <xsl:value-of select="@rows" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>3</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="inputOptions" />
    </textarea>
  </xsl:template>

  <xsl:template match="mir:template[@name='static']" mode="widget">
    <p class="form-control-static {@class}" id="{@id}">
      <xsl:choose>
        <xsl:when test="@xpath">
          <xed:output value="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>

  <xsl:template match="mir:template[@name='checkboxList' or @name='radioList']" mode="widget">
    <xsl:variable name="inputType">
      <xsl:choose>
        <xsl:when test="@name='radioList'">
          <xsl:text>radio</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>checkbox</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="inline" select="@inline" />
    <xsl:variable name="id" select="@id" />

    <xsl:choose>
      <xsl:when test="string-length(@uri) &gt; 0">
        <xsl:variable name="options" select="document(@uri)" />
        <xsl:apply-templates select="$options//option" mode="optionList">
          <xsl:with-param name="id" select="$id" />
          <xsl:with-param name="multiple" select="count($options//option) &gt; 1" />
          <xsl:with-param name="inputType" select="$inputType" />
          <xsl:with-param name="inline" select="$inline" />
          <xsl:with-param name="dynamic" select="true()" />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="option" mode="optionList">
          <xsl:with-param name="id" select="$id" />
          <xsl:with-param name="multiple" select="count(option) &gt; 1" />
          <xsl:with-param name="inputType" select="$inputType" />
          <xsl:with-param name="inline" select="$inline" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="option" mode="optionList">
    <xsl:param name="id" select="''" />
    <xsl:param name="multiple" select="false()" />
    <xsl:param name="inputType" select="'checkbox'" />
    <xsl:param name="inline" select="'false'" />
    <xsl:param name="dynamic" select="false()" />

    <xsl:variable name="gId">
      <xsl:choose>
        <xsl:when test="string-length($id) &gt; 0 and string-length(@value) &gt; 0 and $multiple">
          <xsl:value-of select="concat($id, '-', translate(@value, ' ', '_'))" />
        </xsl:when>
        <xsl:when test="string-length($id) &gt; 0 and $multiple">
          <xsl:value-of select="concat($id, '-{xed:generate-id()}')" />
        </xsl:when>
        <xsl:when test="string-length($id) &gt; 0">
          <xsl:value-of select="$id" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'{xed:generate-id()}'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div>
      <xsl:choose>
        <xsl:when test="$dynamic">
          <!-- workaround for xed:output issue -->
          <xsl:attribute name="class">
            <xsl:text>form-check</xsl:text>
            <xsl:if test="$inline = 'true'">
              <xsl:text> form-check-inline</xsl:text>
            </xsl:if>
          </xsl:attribute>
          <label class="my-0 form-label">
            <input class="form-check-input" type="{$inputType}" value="{@value}" id="{$gId}">
              <xsl:if test="@disabled = 'true'">
                <xsl:attribute name="disabled">
              <xsl:text>disabled</xsl:text>
            </xsl:attribute>
              </xsl:if>
              <xsl:apply-templates select="." mode="inputOptions" />
            </input>
            <xsl:if test="string-length(@i18n) &gt; 0">
              <xed:output i18n="{@i18n}" />
            </xsl:if>
          </label>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">
            <xsl:text>custom-control</xsl:text>
            <xsl:value-of select="concat(' custom-', $inputType)" />
            <xsl:if test="$inline = 'true'">
              <xsl:text> custom-control-inline</xsl:text>
            </xsl:if>
          </xsl:attribute>

          <input class="form-check-input" type="{$inputType}" value="{@value}" id="{$gId}">
            <xsl:if test="@disabled = 'true'">
              <xsl:attribute name="disabled">
              <xsl:text>disabled</xsl:text>
            </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="." mode="inputOptions" />
          </input>
          <label class="form-check-label form-label" for="{$gId}">
            <xsl:if test="string-length(@i18n) &gt; 0">
              <xed:output i18n="{@i18n}" />
            </xsl:if>
          </label>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="mir:template" mode="inputOptions">
    <xsl:if test="string(number(@maxlength)) != 'NaN'">
      <xsl:attribute name="maxlength">
        <xsl:value-of select="@maxlength" />
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@disabled = 'true'">
      <xsl:attribute name="disabled">
        <xsl:text>disabled</xsl:text>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="contains('textInput|passwordInput|textArea', @name) and string-length(@placeholder) &gt; 0">
      <xsl:attribute name="placeholder">
        <xsl:choose>
          <xsl:when test="starts-with(@placeholder, 'i18n:')">
            <xsl:value-of select="concat('{', @placeholder, '}')" />
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="@placeholder" />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mir:template" mode="label">
    <xsl:variable name="colsize">
      <xsl:choose>
        <xsl:when test="$input-size = 'xs'">
          <xsl:value-of select="concat('col-', $label-width)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('col-', $input-size, '-', $label-width)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <label for="{@id}" class="{$colsize} col-form-label text-md-end form-label">
      <xed:output i18n="{@i18n}" />
    </label>
  </xsl:template>

  <xsl:template match="mir:template" mode="inputTooltip">
    <xsl:if test="@tooltip">
      <span class="input-group-text" data-bs-toggle="tooltip" data-html="true">
        <xsl:attribute name="title">
          <xsl:value-of select="concat('{i18n:',@tooltip,'}')" />
        </xsl:attribute>
        <i class="fas fa-info-circle" />
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mir:template" mode="action">
    <xsl:if test="count(action) &gt; 0">
      <xsl:for-each select="action">
        <xsl:variable name="id">
          <xsl:choose>
            <xsl:when test="string-length(@id) &gt; 0">
              <xsl:value-of select="@id" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>{xed:generate-id()}</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <button id="{$id}" class="btn btn-secondary" type="button" aria-label="{concat('{i18n:', @i18n,'}')}">
          <xsl:if test="string-length(@i18n) &gt; 0 and (string-length(@icon) &gt; 0 and @iconOnly = 'true')">
            <xsl:attribute name="title">
            <xsl:value-of select="concat('{i18n:',@i18n,'}')" />
          </xsl:attribute>
          </xsl:if>
          <xsl:if test="string-length(@icon) &gt; 0">
            <span class="{@icon}" aria-hidden="true" />
          </xsl:if>
          <xsl:choose>
            <xsl:when
              test="string-length(@i18n) &gt; 0 and (string-length(@icon) = 0 or (string-length(@icon) &gt; 0 and (string-length(@iconOnly) = 0 or @iconOnly = 'false')))"
            >
              <xsl:choose>
                <xsl:when test="string-length(@icon) &gt; 0">
                  <span class="d-none d-md-inline">
                    <xed:output i18n="{@i18n}" />
                  </span>
                </xsl:when>
                <xsl:otherwise>
                  <xed:output i18n="{@i18n}" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="string-length(@i18n) &gt; 0 and string-length(@icon) &gt; 0">
              <span class="sr-only">
                <xed:output i18n="{@i18n}" />
              </span>
            </xsl:when>
          </xsl:choose>
        </button>
      </xsl:for-each>

    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
