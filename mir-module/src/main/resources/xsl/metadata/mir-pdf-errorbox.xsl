<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xalan="http://xml.apache.org/xalan"
                version="1.0" exclude-result-prefixes="i18n mcrxsl">

    <xsl:param name="ServletsBaseURL"/>


    <xsl:template match="mycoreobject" mode="displayPdfError">
        <xsl:variable name="errorMessages">
            <xsl:apply-templates select="structure/derobjects/derobject" mode="displayPdfError"/>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($errorMessages)) >0">
            <xsl:variable name="couldNotBeValidated">
                <xsl:choose>
                    <xsl:when test="contains($errorMessages,i18n:translate('pdf.errorbox.validationerror.message'))">
                        <xsl:value-of select="'true'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'false'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="containsValidationError">
                <xsl:choose>
                    <xsl:when test="contains($errorMessages,i18n:translate('pdf.errorbox.clause'))">
                        <xsl:value-of select="'true'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'false'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="CaughtException">
                <xsl:choose>
                    <xsl:when test="contains($errorMessages,i18n:translate('pdf.error.runtimeerror.message'))">
                        <xsl:value-of select="'true'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'false'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="validationWasSuccessfull">
                <xsl:choose>
                    <xsl:when test="$couldNotBeValidated='false' and $containsValidationError='false' and $CaughtException='false'">
                        <xsl:value-of select="'true'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'false'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="$validationWasSuccessfull='false' and $CaughtException='false'">
                    <div class="container pdf-validation mb-3 px-0" id="accordion">
                        <div class="card-header bg-danger text-white">
                            <div class="list-group list-group-root well p-3">
                                <p class="h5">
                                    <xsl:value-of select="i18n:translate('pdf.errorbox.warning.heading')"/>
                                </p>
                                <p>
                                    <xsl:value-of select="i18n:translate('pdf.errorbox.warning.message')"/>
                                </p>
                            </div>
                        </div>
                        <div class="card-body border-left border-right border-bottom">
                            <xsl:copy-of select="$errorMessages"/>
                        </div>
                    </div>
                </xsl:when>
                <xsl:when test="$validationWasSuccessfull='true'">
                    <div class="card-header bg-success text-white mb-3">
                        <div class="list-group list-group-root well p-3">
                            <p class="h5">
                                <xsl:value-of select="i18n:translate('pdf.errorbox.success.heading')"/>
                            </p>
                            <p>
                                <xsl:value-of select="i18n:translate('pdf.errorbox.success.message')"/>
                            </p>
                        </div>
                    </div>
                </xsl:when>
                <xsl:otherwise> <xsl:copy-of select="$errorMessages"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template match="structure/derobjects/derobject" mode="displayPdfError">
        <xsl:variable name="derivateID" select="@xlink:href"/>
        <xsl:variable name="result" select="document(concat('catchEx:pdfAValidator:', $derivateID))"/>
            <xsl:choose>
            <xsl:when test="not(normalize-space($result))">
                <xsl:apply-templates select="$result/derivate/file" mode="displayPdfError"/>
            </xsl:when>
            <xsl:otherwise>
                <div class="card text-white bg-danger mb-3 pdfa-runtime-exception">
                    <div class="card-header">
                        <xsl:value-of select="concat($derivateID,': ',$result)"/>
                    </div>
                    <div class="card-body">
                        <p class="card-text">
                            <xsl:value-of select="i18n:translate('pdf.error.runtimeerror.message')"/>
                        </p>
                        <p class="card-text fst-italic">
                            <xsl:value-of select="i18n:translate('mir.error.finalLine')"/>
                        </p>
                    </div>
                </div>

            </xsl:otherwise>
            </xsl:choose>
    </xsl:template>



    <xsl:template match="file" mode="displayPdfError">
        <xsl:variable name="ValidationError" select="@flavour = 'Validation Error'"/>

        <xsl:variable name="derivate" select="../@id"/>
        <xsl:variable name="name">
            <xsl:call-template name="pdfError.getFilename">
                <xsl:with-param name="filePath" select="@name"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="badgecolor">
            <xsl:choose>
                <xsl:when test="$ValidationError">warning</xsl:when>
                <xsl:when test="failed">danger</xsl:when>
                <xsl:otherwise>success</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="uniqueFileId" select="generate-id(.)"/>
        <div id="{$derivate}{$uniqueFileId}" class="font-weight-bold d-flex list-group list-group-root">
            <a onclick="$('#{$derivate}{$uniqueFileId}cbButton').toggleClass('fa-chevron-right fa-chevron-down');"
               data-toggle="collapse" href="#collapse{$derivate}{$uniqueFileId}"
               class="text-start d-flex flex-md-row flex-grow-1 list-group-item align-items-center">
                <i id="{$derivate}{$uniqueFileId}cbButton" class="fa fa-chevron-right ms-auto me-1"/>
                <span class="flex-grow-1 font-weight-bold text-break">
                    <xsl:value-of select="$name"/>
                </span>
                <span class="badge bg-{$badgecolor} rounded-pill align-self-center">
                    <xsl:choose>
                        <xsl:when test="$badgecolor = 'warning'">!</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="count(failed)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </a>
        </div>
        <ul class="list-group collapse" id="collapse{$derivate}{$uniqueFileId}">
            <li class="list-group-item d-flex flex-column flex-xl-row flex-grow-2 text-break">
                <xsl:choose>
                    <xsl:when test="$ValidationError">
                        <xsl:apply-templates select="failed" mode="displayValidationError"/>
                        <span class="flex-grow-1 col-xl-8 align-items-center">
                            <p class="text-danger mb-2">
                                <xsl:value-of select="i18n:translate('pdf.errorbox.validationerror.message')"/>
                            </p>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <p class="flex-grow-1 col-xl-8 align-items-center">
                            <span class="text-muted pdf-term">
                                <xsl:value-of select="concat(i18n:translate('pdf.errorbox.conformity.level'), ': ')"/>
                            </span>
                            <span class="pdf-value">
                                <xsl:value-of select="concat('PDF/A-', @flavour)"/>
                            </span>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:variable name="downloadLink"
                              select="concat($ServletsBaseURL, 'MCRFileNodeServlet/', $derivate, '/', mcrxsl:encodeURIPath(@name))"/>
                <div class="w-100 d-flex align-self-center justify-content-center">
                    <a role="button" href="{$downloadLink}" target="_blank"
                       class="btn btn-primary d-flex justify-content-center align-items-center w-100 py-2">
                        <xsl:value-of select="concat(i18n:translate('pdf.errorbox.button.download'), ' ')"/>
                        <i class="fas fa-download ms-2"/>
                    </a>
                </div>
            </li>

            <xsl:choose>
                <xsl:when test="not($ValidationError)">
                    <xsl:apply-templates select="failed" mode="displayPdfError"/>
                </xsl:when>
                <xsl:when test="$ValidationError">
                    <xsl:apply-templates select="exceptions">
                        <xsl:with-param name="uniqueName" select="concat($derivate, $uniqueFileId)"/>
                    </xsl:apply-templates>
                </xsl:when>
            </xsl:choose>
        </ul>
    </xsl:template>

    <xsl:template match="exceptions">
        <xsl:param name="uniqueName" select="'uniqueStacktraceName'"/>
        <a onclick="$('#{$uniqueName}stacktracecbButton').toggleClass('fa-chevron-right fa-chevron-down');"
           data-toggle="collapse" href="#collapse{$uniqueName}stacktrace"
           class="text-start text-dark d-flex flex-md-row flex-grow-1 list-group-item align-items-center"
           style="text-decoration: none;">
            <i id="{$uniqueName}stacktracecbButton" class="fa fa-chevron-right ms-auto me-1"></i>
            <span class="flex-grow-1 font-weight-bold text-break">
                <xsl:value-of select="'Stack trace'"/>
            </span>
        </a>
        <div id="collapse{$uniqueName}stacktrace" class="collapse list-group-item text-center"
             style="overflow-x: auto;">
            <xsl:for-each select="exception">
                <xsl:call-template name="render-exception">
                    <xsl:with-param name="exception" select="."/>
                </xsl:call-template>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="render-exception">
        <xsl:param name="exception"/>


        <xsl:variable name="currentId" select="generate-id($exception)"/>

        <ul class="list-unstyled ps-3" id="{$currentId}">
            <li class="alert alert-info" role="alert">
                <xsl:value-of select="$exception/message/@message"/>
            </li>
            <li class="text-primary fst-italic" style="font-size: 1em;">
                <xsl:value-of select="$exception/class/@name"/>
            </li>
            <xsl:call-template name="render-exception-details">
                <xsl:with-param name="exception" select="$exception"/>
            </xsl:call-template>
        </ul>

        <xsl:if test="$exception/suppressed/exception">
            <xsl:for-each select="$exception/suppressed/exception">
                <xsl:call-template name="render-exception">
                    <xsl:with-param name="exception" select="."/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="render-exception-details">
        <xsl:param name="exception"/>


        <pre style="font-size: 0.8em;">
            <code>
                <xsl:for-each select="$exception/stackTrace/frame">
                    <xsl:value-of select="@text"/>
                    <xsl:text>&#10;</xsl:text>
                </xsl:for-each>
            </code>
        </pre>


        <xsl:if test="$exception/cause/exception">
            <p>
                <strong>Caused by:</strong>
            </p>
            <xsl:text>&#10;</xsl:text>
            <li class="alert alert-info" role="alert">
                <xsl:value-of select="$exception/cause/exception/message/@message"/>
            </li>
            <li class="text-primary fst-italic" style="font-size: 1em;">
                <xsl:value-of select="$exception/cause/exception/class/@name"/>
            </li>
            <xsl:call-template name="render-exception-details">
                <xsl:with-param name="exception" select="$exception/cause/exception"/>
            </xsl:call-template>
        </xsl:if>


        <xsl:for-each select="$exception/suppressed/exception">
            <li class="alert alert-info" role="alert">
                <xsl:value-of select="$exception/suppressed/exception/message/@message"/>
            </li>
            <li class="text-primary fst-italic" style="font-size: 1em;">
                <xsl:value-of select="$exception/suppressed/exception/class/@name"/>
            </li>
            <p>Suppressed:</p>
            <xsl:call-template name="render-exception-details">
                <xsl:with-param name="exception" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="failed" mode="displayPdfError">
        <li class="list-group-item d-flex flex-column flex-xl-row flex-grow-1 text-break">
            <p class="flex-grow-1 col-xl-8 align-items-center">
                <span class="text-muted pdf-term">
                    <xsl:value-of select="concat(i18n:translate('pdf.errorbox.specification'),': ')"/>
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @specification, ' ')"/>
                </span>
                <span class="text-muted pdf-term">
                    <xsl:value-of select="concat(i18n:translate('pdf.errorbox.clause'),': ')"/>
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @clause, ' ')"/>
                </span>
                <span class="text-muted pdf-term">
                    <xsl:value-of select="concat(i18n:translate('pdf.errorbox.test'),': ')"/>
                </span>
                <span class="pdf-value">
                    <xsl:value-of select="concat(' ', @testNumber, ' ')"/>
                </span>
            </p>
            <xsl:choose>
                <xsl:when test="not(@link)">
                    <div class="w-100 d-flex align-self-center justify-content-center">
                        <a role="button" href="{@Link}" target="_blank"
                           class="btn btn-info col d-flex justify-content-center align-items-center w-100 py-2">
                            <xsl:value-of select="concat(i18n:translate('pdf.errorbox.button.info'),' ')"/>
                            <i class="fas fa-external-link-alt ms-2"></i>
                        </a>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div class="text-center alert alert-danger col" role="alert">
                        <xsl:value-of select="i18n:translate('pdf.errorbox.unknown.error')"/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="failed" mode="displayValidationError">
        <span class="flex-grow-1 col-xl-8 align-items-center">
            <p class="text-danger mb-2">
                <xsl:value-of select="i18n:translate('pdf.errorbox.validationerror.message')"/>
            </p>
        </span>
    </xsl:template>


    <xsl:template name="pdfError.getFilename">
        <xsl:param name="filePath"/>
        <xsl:variable name="rest-of" select="substring-after($filePath, '/')"/>
        <xsl:choose>
            <xsl:when test="contains($rest-of, '/')">
                <xsl:call-template name="pdfError.getFilename">
                    <xsl:with-param name="filePath" select="$rest-of"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="normalize-space($rest-of)">
                    <xsl:value-of select="$rest-of"/>
                </xsl:if>
                <xsl:if test="not(normalize-space($rest-of))">
                    <xsl:value-of select="$filePath"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
